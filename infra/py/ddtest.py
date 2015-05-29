#!/usr/bin/env python
#
#   Copyright 2015 Dario Domizioli
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

"""
ddtest.py is a useful testing utility. It can run a test individually,
producing a result file, and it can also gather a collection of result files and
create a properly formatted junit XML file.

To run a test, use:
    ddtest.py  --run   RESULT_FILE   TEST_SOURCE   [PROGRAM_FILE]

RESULT_FILE will be created and populated with a first line which is either PASS
or FAIL and then the stderr and stdout log of the run.

TEST_SOURCE is the source for the test. This can contain RUN directives embedded
in the comments for whatever language the source is written in. At the moment
the only supported comments are:
; <comment>
// <comment> (usually C/C++ files)
# <comment>  (usually Python, or shell, or make, or Verilog...)
-- <comment> (usually for ADA or VHDL files)

PROGRAM_FILE is (optionally) a specific program under test, which can be a
system test program for a library project or a built program for a program
project. If PROGRAM_FILE is not provided, it is assumed that the RUN directives
embedded in the test source will be able to access any program they need access
to, and it is the test's responsibility to make sure it is the case.

Any line starting with comment characters will be processed and if the first
word of the comment is RUN, then the rest of the line is the command line to
run. The ddtest.py script performs some substitutions on the command line:
%P is the PROGRAM_FILE (if provided)
%S is the TEST_SOURCE
%T is a single temporary file that can be created by ddtest.py if needed.
   (once created, every occurrence of %T refers to that file)

For example:
// RUN %P %S >%T
// RUN grep "foo" %T
// RUN grep "bar" %T
This test will run the program on the source, generating some output that is
then searched for both strings "foo" and "bar".

If any of the commands that were run exits with a non-zero code, the test is a
FAIL, otherwise it's a PASS.

To gather test results and generate a junit XML report, use:
    ddtest.py  --gather   JUNIT_FILE   FILES...

This will process all the FILES and create the report according to the state of
each test (which is in the first line of the test result).
"""

import sys
import os
import re
import subprocess
import tempfile


USAGE_TEXT = """
Usage:
    ddtest.py --run   RESULT_FILE   TEST_SOURCE   [PROGRAM_FILE]
    ddtest.py --gather   JUNIT_FILE   FILES...

--run runs a test and generates a result file.
--gather processes test result FILES and generates a junit XML report, then it
         returns an exit code of zero if all tests have passed.

"""


def run (*cmd_line, **kwargs):
    """Runs a command line and returns (stdout, stderr, exit_code).
       Kwargs can be 'cwd', which sets the working directory, and 'env' which
       overrides the environment. Also passing 'stdin_value' will send the data
       to the stdin pipe."""
    stdin_value = kwargs.get ("stdin_value", None)
    if stdin_value != None:
        stdin_value = str(stdin_value) # copy it
        del kwargs["stdin_value"]
    process = subprocess.Popen (args =   cmd_line, 
                                stdin = subprocess.PIPE,
                                stdout = subprocess.PIPE, 
                                stderr = subprocess.PIPE,
                                universal_newlines = True,
                                **kwargs)
    (stdout, stderr) = process.communicate (stdin_value)
    return (stdout, stderr, process.returncode)


def run_single_test():
    """Runs a single test. See the module help for documentation."""
    arguments = list()
    for item in sys.argv[1:]:
        if item != "--run":
            arguments.append(item)
    if len(arguments) != 2 and len(arguments) != 3:
        sys.stderr.write(USAGE_TEXT)
        sys.exit(1)

    run_comment_re = re.compile(r"(;|//|#|--)\s+RUN:?\s+(.*)")
    program_subst_re = re.compile(r"(.*)(%P|%p)(.*)")
    testsource_subst_re = re.compile(r"(.*)(%S|%s)(.*)")
    tempfile_subst_re = re.compile(r"(.*)(%T|%t)(.*)")

    cmd_lines_to_run = list()
    result_file = arguments[0]
    test_file = arguments[1]
    program_file = arguments[2] if len(arguments) > 2 else ""
    with tempfile.NamedTemporaryFile() as temp_file:
        with open(test_file) as tfile:
            for line in tfile:
                # If line is a RUN comment, process the command line
                match = run_comment_re.match(line)
                if match:
                    cmd_line = match.group(2)
                    # Substitute instances of %P with the program
                    m = program_subst_re.match(cmd_line)
                    while m is not None:
                        cmd_line = m.group(1) + program_file + m.group(3)
                        m = program_subst_re.match(cmd_line)
                    # Substitute instances of %S with the test source
                    m = testsource_subst_re.match(cmd_line)
                    while m is not None:
                        cmd_line = m.group(1) + test_file + m.group(3)
                        m = testsource_subst_re.match(cmd_line)
                    # Substitute instances of %T with the temporary file
                    m = tempfile_subst_re.match(cmd_line)
                    while m is not None:
                        cmd_line = m.group(1) + temp_file.name + m.group(3)
                        m = tempfile_subst_re.match(cmd_line)
                    processed_cmd_line = [cmd_line]
                    cmd_lines_to_run.append(processed_cmd_line)
        # Now run properly
        passed = True
        acc_log = ""
        for cmd_line in cmd_lines_to_run:
            (stdout, stderr, exit_code) = run(*cmd_line, shell = True)
            acc_log += stderr
            acc_log += stdout
            passed = passed and (exit_code == 0)
            if not passed:
                break
        # And write the result file
        with open(result_file, "w") as rfile:
            rfile.write("PASS\n" if passed else "FAIL\n")
            rfile.write(acc_log)
    return 0


def gather_test_results():
    """Gathers test results. See the module help for documentation."""
    arguments = list()
    for item in sys.argv[1:]:
        if item != "--gather":
            arguments.append(item)
    if len(arguments) < 1:
        sys.stderr.write(USAGE_TEXT)
        sys.exit(1)
    junit_file = arguments[0]
    failures = 0
    tests = len (arguments[1:])
    # Gather data.
    acc_text = ""
    acc_log = ""
    for result_file in arguments[1:]:
        with open(result_file, "r") as rfile:
            failing = False
            for line in rfile:
                if not failing and line.strip() == "PASS":
                    acc_text += '    <testcase name="{0}"/>\n'.format(
                        os.path.splitext(result_file)[0])
                    break
                else:
                    if not failing: # this means: first line of failed test
                        failing = True
                        acc_text += '    <testcase name="{0}">\n'.format(
                            os.path.splitext(result_file)[0])
                        acc_text += '      <failure>{0}</failure>\n'.format(
                            'Log is in ' + result_file)
                        acc_text += '    </testcase>\n'
                        failures += 1
                        bname = os.path.basename(result_file)
                        sys.stderr.write("--{0}{1}\n".format(bname, "-" * (78 - len(bname))))
                    else: # append further lines to the accumulated log
                        to_add = "{0}\n".format(line)
                        acc_log += to_add
                        sys.stderr.write(to_add)
        # Ok, now write the report file.
    with open(junit_file, "w") as jfile:
        jfile.write("<testsuites>\n")
        jfile.write('  <testsuite name="System Tests" ')
        jfile.write('errors="0" failures="{0}" tests="{1}">\n'.format(
                failures, tests))
        jfile.write("{0}".format(acc_text))
        jfile.write("    <system-out></system-out>\n")
        jfile.write("    <system-err>\n{0}    </system-err>\n".format(acc_log))
        jfile.write("  </testsuite>\n")
        jfile.write("</testsuites>\n")
    if failures > 0:
        sys.stderr.write("Encountered {0} failures in system tests.\n".format(
            failures))
        return 1
    return 0


if __name__ == "__main__":
    if "--run" in sys.argv:
        sys.exit(run_single_test())
    if "--gather" in sys.argv:
        sys.exit(gather_test_results())
    sys.stderr.write(USAGE_TEXT)
    sys.exit(1)
