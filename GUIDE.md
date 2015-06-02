# `dd-star` User Guide

## Getting started

In order to get started using the `dd-star` environment for your project, make
sure your system satisfies its few prerequisites.

* Make sure you have GNU Make 3.81 or later by trying `make --version`.
* Make sure you have Python 2.7 by trying `python --version`.
* You should have `git`, but check its version is 1.7 or later with `git help`.
* Do you want Doxygen documentation? In which case make sure `doxygen --version`
  reports 1.8.x or a later version.

Also, of course you should have a C++ compiler. At the moment `dd-star` supports
`gcc` and `clang`.

To test the prerequisites, check that you can build a clone of `dd-star`.

    $ git clone https://github.com/hhexo/dd-star.git
    ...
    $ cd dd-star
    $ make reset
    ...
    $ make everything
    ...

If the build is successful, then you have all the prerequisites and can start
hacking on your `dd-star` based project.

## The `dd-star` structure

### Overall structure

The `dd-star` environment is structured with a `core` project and a number of
`satellite` projects.

The `satellite` projects all depend on `core`, and the build system is already
handling the library dependencies and the include directories so that the
satellites can be built.

In general, the satellites don't depend on each other: the idea is that if some
functionality is common, it should be in `core`! This is the reason for the
"star" in `dd-star`, the dependency graph is a star with `core` at its centre.

On the file system, the directories are organized as follows:

    <top>
    |
    +-- core
    |
    +-- satellites
    |   |
    |   +-- example-library
    |   |
    |   +-- example-program
    |
    +-- deps
    +-- infra

The `deps` and `infra` directories contain the vital files that make the
`dd-star` environment work and should not be tampered with.

Two example satellite projects are provided as a starting point for further
projects.

### Individual project structure

Every single project, whether it is `core` or any of the `satellites`, must
follow exactly this directory structure:

    <project_name>
    |
    +-- doc
    |
    +-- include
    |   |
    |   +-- <project_name>
    |
    +-- src
    |
    +-- test
    |   |
    |   +-- unit
    |   |
    |   +-- system
    |
    +-- Makefile

The `doc` directory is optional, and it can contain Markdown files that serve as
additional documentation for the project. For example they can be used to
specify file formats, or for a user guide.

The `include` directory must contain a subdirectory with the same name as the
project. All header files that are exported as part of the product (i.e. all the
ones that are user-visible) should live underneath that directory.

The `src` directory contains the project's source files and all the header files
that should not be exported as part of the product.

Header files must have a `.h` extension, and source files must have a `.c` (if
written in C) or `.cpp` (if written in C++) extension.

The `test/unit` directory contains C++ source files, each of which is assumed to
contain a number of CATCH-based unit tests. The build system will compile these
files and link them with an automatically generated main file. The resulting
executable will run all unit tests.

The `test/system` directory contains C++ source files and other text files. For
every `.cpp` file underneath the directory tree, a program will be created: the
file is assumed to have a `main()` function and it is linked with the project
library. The source file must also have comments specifying how to run the test:
the `ddtest.py` utility used by the build system will parse those comments and
run the test accordingly. System tests that are not C++ files are still
processed by the `ddtest.py` utility for comments specifying how to run the
test, but of course do not need to be compiled first.

For a better explanation of how to manage tests, see later sections.

The `Makefile` for each project contains some boilerplate and a reference to
other standard make files that live in the `infra` subtree of `dd-star`. The
whole implementation of the build system is in `infra`, so that individual
projects only have to specify a small number of variables and then refer to the
standard implementation.

### The structure of the final product

Upon a successful build of at least one project, a `product` directory is
created at the top level, with the following structure.

    <top>
    |
    +-- ...
    |
    +-- product
        |
        +-- bin
        |
        +-- doc
        |
        +-- include
        |
        +-- lib
        |
        +-- test-results

The `bin` subdirectory will contain all executable binary files created by all
the projects that have been built. Similarly, the `lib` subdirectory will
contain all the libraries thus built.

"Release" binaries are placed directly within `bin` or `lib`, but "Debug" and
"Checking" binaries are also provided underneath the `debug` and `checking`
subdirectories. As for what these specifiers mean, here is a quick guide:

* "Release" is a fully optimized build with no debug info and no assertions.
* "Checking" is a fully optimized build with debug info and assertions.
* "Debug" is a non-optimized build with debug info and assertions.
* The "Checking" build is used in unit tests and system tests.

The `include` subdirectory will contain copies of the `include` trees of each
individual project.

The `doc` subtree will contain, for each project, its "reference" documentation
(which is the one generated by Doxygen from the source), and its "additional"
documentation (which is generated from the Markdown files in its `doc`
directory, if any).

Finally, the `test-results` subtree will contain, for each project, two JUnit
XML files detailing the results of the unit and system tests of the project.


## Using `dd-star` for your projects

This section of the guide contains a lot of "how to" subsections illustrating
typical use cases of working with `dd-star`.

### How to initialise your `dd-star` based project

To start working in a `dd-star` based environment, you could clone the `dd-star`
repository and then just remove the .git directory...

    git clone https://github.com/hhexo/dd-star.git <your_project_name>
    cd <your_project_name>
    rm -fr .git

However, this will overwrite your `.git` directory if you've already got it
(say, if you have created an empty project on GitHub and then cloned it). A
better way to do this is to use `git archive` to create a tar file and then
expanding it in your project directory.

    cd <your_project_name>
    git archive --remote=https://github.com/hhexo/dd-star.git -o dd-star.tar
    tar -xvf dd-star.tar
    rm -f dd-star.tar

Note this will still overwrite other files: your top level `.gitignore`,
your `README.md`, and your `LICENSE` and `NOTICE` files if you have them.
Furthermore, a copy of this `GUIDE.md` will be created. You can delete it.

### How to build or clean all the projects

To build all projects, run `make everything` from the top level.

To clean all projects, run `make reset` from the top level. This also destroys
the `product` subdirectory.

### How to build and install a single project

To build and install a single project, just run `make <project_name>`.

This is equivalent to running the `install` target for the specified project,
which can be `core` or any of the satellites.

### How to run a particular Make target of a project

The `dd-star` build system allows to call `make` on a set of standard targets
that all projects will support. These are:

    clean
    debug
    release
    checking
    all
    tests
    docs
    install

In order to run one of these targets from the top level, run:

    make <project_name>-<target_name>

A few examples follow.

    make core-clean
    make core-install
    make example-program-all
    make example-program-docs

Note that all satellite projects depend on `core`. Therefore, any build of any
target other than `clean` for a satellite project has a prerequisite of
`core-install`.

### How to create a new satellite project

This operation is very easy if `example-library` and `example-program` are still
in the tree of the satellite projects.

First of all, copy one of the two example satellite projects in a new directory
at the same level. For example:

    cd satellites
    cp -r example-program new-project

Then, modify the boilerplate code in its `Makefile`, changing the variable
specifying the "main sources" of the project, if you have any. For example:

    PROJECT_MAIN_SRCS := src/my_main_source.cpp

... and that's it! Nothing else to do! The standard build system already takes
care of everything.

You can then start hacking your new satellite project.

### How to add headers and source files in a project

Whether you are adding to the `core` project or to a `satellite` project, this
operation is the same.

If your header is going to be user-visible and needs to be exported, place it
in the `include` subtree of the project.

Any other source or header should live in the `src` subtree of the project.

Once the file has been created, it is automatically discovered by the build
system, as long as its extension is `.h`, `.c` or `.cpp`.

### How to add unit tests

Unit tests must be `.cpp` files that live in the `test/unit` subtree of the
project.

The `dd-star` environment bundles a copy of Phil Nash's CATCH unit testing
framework. It is a header-only implementation and therefore in order to use it
it is sufficient to have a `#include` directive like this:

    #include <catch/catch.hpp>

Please refer to https://github.com/philsquared/Catch for the documentation of
the CATCH framework.

Unit tests that do not use the CATCH framework will still be compiled, however
they will not be run automatically!

If you want to write custom test that exercise portions of your code without
using CATCH, you can still write them as system tests, as explained below.

### How to add system tests

System tests are handled by the `ddtest.py` utility which lives in the
`infra/py` subdirectory of `dd-star`. This little utility allows the build
system to run tests as specified in any text file found under the `test/system`
subtree of each project. `ddtest.py` is loosely inspired by LLVM's `lit` test
infrastructure program, but it is far, far simpler in scope.

There are two types of system tests: program-based system tests, and generic
system tests.

#### Adding a program-based test

Any `.cpp` file found under the `test/system` subtree of a project is considered
a program-based test. This means that this source will be compiled and linked
against the project's libraries, producing a test program, before the actual
test is run.

The `ddtest.py` utility then inspects the source `.cpp` file for comments of the
form:

    // RUN: <command line>

or

    // RUN <command line>

(the colon is optional)

For every command line found in such comments, a process is spawned accordingly.
If the exit code of any such process is not zero, the test will be considered as
failed.

It is possible to use specific variables in the command line which will be
automatically substituted by `ddtest.py` with certain values.

* `%P` is the path to the program compiled and linked from the test source file.
* `%S` is the path to the test source file.
* `%T` is a temporary file which `ddtest.py` creates and which will exist for
  the duration of the test.

For example, let's say that our test source file is called `MyTest.cpp`, and it
contains these comments:

    // RUN: %P --some-option >%T
    // RUN: grep "OK" %T

The system will first compile `MyTest.cpp` to an executable called `MyTest`
somewhere in the build tree. Then, the system will run each command line found
in the comments. The first of such lines will save the output of an invocation
of `MyTest` into the temporary file, and the second one will grep such output
for the string "OK".

Note that this would also be equivalent to:

    // RUN: %P --some-option | grep "OK"

which does not use the temporary file.

#### Adding a generic test

Generic system tests work in the same way as the program-based tests, with the
exception that they are not compiled and linked. This functionality is useful
for testing the executable binaries that are already produced by the projects. 

`ddtest.py` recognizes a number of different comment markers, such as `//`, `#`,
`;` and `--`. Most people will just use the C++ style comments (slashes) or the
script style comments (hashes).

For example, the `example-program` satellite project produces an `example`
executable binary which prints 42. The project has a system test that verifies
such fact, in the form of a non-`cpp` text file which just contains the
following:

    # RUN example >%T
    # RUN grep "42" %T

The system makes sure that, before running the command line, the PATH is set so
that the executables built by the project are on it. In other words, it is not
necessary to specify the full path to `example` (also because it is handled by
the build system so a test writer would not know what the path is!).

