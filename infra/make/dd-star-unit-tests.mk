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

UNIT_TESTS_MAIN_FILE := $(PROJECT_DIRECTORY)/build/test/unit/main.cpp
UNIT_TESTS_MAIN_OBJ := $(PROJECT_DIRECTORY)/build/test/unit/main.opp
UNIT_TESTS_EXECUTABLE := $(PROJECT_DIRECTORY)/build/test/unit/run-unit-tests

# Unit tests must be C++
UNITSRCS := $(wildcard $(PROJECT_DIRECTORY)/test/unit/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/unit/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/unit/*/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/unit/*/*/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/unit/*/*/*/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/unit/*/*/*/*/*/*.cpp) \
            $(wildcard $(PROJECT_DIRECTORY)/test/unit/*/*/*/*/*/*/*.cpp)
UNITOBJS = $(patsubst $(PROJECT_DIRECTORY)/test/unit/%.cpp,$(PROJECT_DIRECTORY)/build/test/unit/obj/%.opp,$(UNITSRCS))
UNITDEPS = $(patsubst $(PROJECT_DIRECTORY)/test/unit/%.cpp,$(PROJECT_DIRECTORY)/build/test/unit/obj/%.dpp,$(UNITSRCS))
$(foreach depfile,$(UNITDEPS),$(eval $(call dep_file_include_line,$(depfile))))

$(PROJECT_DIRECTORY)/build/test/unit/obj/%.opp: $(PROJECT_DIRECTORY)/test/unit/%.cpp
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling unit test file $<..."
	@$(CXX) -c $(CXXFLAGS_CHECKING) $< -o $@

$(PROJECT_DIRECTORY)/build/test/unit/obj/%.dpp: $(PROJECT_DIRECTORY)/test/unit/%.cpp
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CXX) -MM $(CXXFLAGS_CHECKING) -MT $(patsubst $(PROJECT_DIRECTORY)/test/unit/%.cpp,$(PROJECT_DIRECTORY)/build/test/unit/obj/%.opp,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.opp[ :]*,\1.opp $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

# Force running the unit tests if there is at least one
ifneq ($(strip $(UNITSRCS)),)
FORCE_UNIT_TESTS = FORCE
FORCE:
endif

$(UNIT_TESTS_RESULTS_FILE): $(UNIT_TESTS_EXECUTABLE) $(FORCE_UNIT_TESTS)
	@mkdir -p $(PROJECT_DIRECTORY)/build/test/unit/results
	@echo "[$(PROJECT_NAME)] Running unit tests..."
	@($(UNIT_TESTS_EXECUTABLE) -r junit -o $@) || (cat $@)

# Link against the checking library
UNIT_TESTS_LINK_PROJECT_FILES = $(PROJECT_DIRECTORY)/build/lib/checking/$(TARGET_LIBRARY)

$(UNIT_TESTS_EXECUTABLE): $(UNIT_TESTS_MAIN_OBJ) $(UNITOBJS) $(UNIT_TESTS_LINK_PROJECT_FILES)
	@echo "[$(PROJECT_NAME)] Linking unit tests..."
	@$(CXX) $(UNIT_TESTS_MAIN_OBJ) $(UNITOBJS) $(UNIT_TESTS_LINK_PROJECT_FILES) $(LDFLAGS_CHECKING) -o $@

$(UNIT_TESTS_MAIN_OBJ): $(UNIT_TESTS_MAIN_FILE)
	@echo "[$(PROJECT_NAME)] Compiling unit tests main file..."
	@$(CXX) -c $(CXXFLAGS_CHECKING) $< -o $@

$(UNIT_TESTS_MAIN_FILE):
	@mkdir -p $(PROJECT_DIRECTORY)/build/test/unit
	@echo "[$(PROJECT_NAME)] Autogenerating main file for unit tests..."
	@echo "" >$@
	@echo "// GENERATED FILE. DO NOT EDIT." >>$@
	@echo "" >>$@
	@echo "#define CATCH_CONFIG_MAIN" >>$@
	@echo "" >>$@
	@echo "#include <catch/catch.hpp>" >>$@
	@echo "" >>$@
	@echo "namespace {} // just to have something in here" >>$@
	@echo "" >>$@
