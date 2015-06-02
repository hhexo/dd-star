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

# C++ sources in the system tests directories are library system tests. Each one
# should have a main() that performs the test, and should be invoked via ddtest
# directives written in the source itself.
SYST_TESTS_LINK_PROJECT_FILES = -L$(PROJECT_DIRECTORY)/build/lib/checking -l$(PROJECT_NAME)

SYSTSRCS := $(wildcard $(PROJECT_DIRECTORY)/test/system/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*/*/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*/*/*/*/*.cpp)
SYSTDEPS = $(patsubst $(PROJECT_DIRECTORY)/test/system/%.cpp,$(PROJECT_DIRECTORY)/build/test/system/obj/%.dpp,$(SYSTSRCS))
SYSTEXES = $(patsubst $(PROJECT_DIRECTORY)/test/system/%.cpp,$(PROJECT_DIRECTORY)/build/test/system/obj/%,$(SYSTSRCS))
SYSTSRCSRESULTS = $(patsubst $(PROJECT_DIRECTORY)/test/system/%.cpp,$(PROJECT_DIRECTORY)/build/test/system/obj/%.result,$(SYSTSRCS))
$(foreach depfile,$(SYSTDEPS),$(eval $(call dep_file_include_line,$(depfile))))

$(PROJECT_DIRECTORY)/build/test/system/obj/%: $(PROJECT_DIRECTORY)/test/system/%.cpp $(PROJECT_DIRECTORY)/build/lib/checking/$(TARGET_LIBRARY)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling and linking system test file $<..."
	@$(CXX) $< $(CXXFLAGS_CHECKING) $(SYST_TESTS_LINK_PROJECT_FILES) $(LDFLAGS_CHECKING) -o $@

$(PROJECT_DIRECTORY)/build/test/system/obj/%.dpp: $(PROJECT_DIRECTORY)/test/system/%.cpp
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CXX) -MM $(CXXFLAGS_CHECKING) -MT $(patsubst $(PROJECT_DIRECTORY)/test/system/%.cpp,$(PROJECT_DIRECTORY)/build/test/unit/obj/%.opp,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.opp[ :]*,\1 $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

$(PROJECT_DIRECTORY)/build/test/system/obj/%.result: $(PROJECT_DIRECTORY)/test/system/%.cpp $(PROJECT_DIRECTORY)/build/test/system/obj/%
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Running system test $<..."
	@env PATH=$$PATH:$(PROJECT_DIRECTORY)/build/bin/checking $(PYTHON) $(DDSTAR_TOP_LEVEL_DIR)/infra/py/ddtest.py --run $@ $+

tests: $(SYSTEXES)

# System tests for programs must be text files. Each one contains test
# directives for ddtest and can be used as the argument to the program under
# test.
SYST_ALL_TEXTS := $(wildcard $(PROJECT_DIRECTORY)/test/system/*) \
                  $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*) \
                  $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*) \
                  $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*/*) \
                  $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*/*/*) \
                  $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*/*/*/*) \
                  $(wildcard $(PROJECT_DIRECTORY)/test/system/*/*/*/*/*/*/*)
SYST_TEXTS_AND_DIRS := $(filter-out $(SYSTSRCS),$(SYST_ALL_TEXTS))
SYST_SPURIOUS_DIRS := $(patsubst %/.,%,$(wildcard $(addsuffix /.,$(SYST_TEXTS_AND_DIRS))))
SYSTTEXTS := $(filter-out $(SYST_SPURIOUS_DIRS),$(SYST_TEXTS_AND_DIRS))
SYSTTEXTRESULTS = $(patsubst $(PROJECT_DIRECTORY)/test/system/%,$(PROJECT_DIRECTORY)/build/test/system/txt/%.result,$(SYSTTEXTS))

$(PROJECT_DIRECTORY)/build/test/system/txt/%.result: $(PROJECT_DIRECTORY)/test/system/% $(CHECKING_PROGRAMS)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Running system test $(firstword $+)..."
	@env PATH=$$PATH:$(PROJECT_DIRECTORY)/build/bin/checking $(PYTHON) $(DDSTAR_TOP_LEVEL_DIR)/infra/py/ddtest.py --run $@ $<

SYSTRESULTS = $(SYSTSRCSRESULTS) $(SYSTTEXTRESULTS)
$(SYSTEM_TESTS_RESULTS_FILE): $(SYSTRESULTS)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Gathering system test results..."
	@env PATH=$$PATH:$(PROJECT_DIRECTORY)/build/bin/checking $(PYTHON) $(DDSTAR_TOP_LEVEL_DIR)/infra/py/ddtest.py --gather $@ $+
