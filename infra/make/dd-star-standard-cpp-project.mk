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

# Check we have defined DDSTAR_TOP_LEVEL_DIR before entering this file.
ifeq ($(strip $(DDSTAR_TOP_LEVEL_DIR)),)
$(error DDSTAR_TOP_LEVEL_DIR must be defined when running sub-makefiles. Try running make from the top level)
endif

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-dirs-and-projects.mk

# Check we have defined the input parameters
ifeq ($(strip $(PROJECT_NAME)),)
$(error PROJECT_NAME must be defined when using the standard cpp makefile)
endif
ifeq ($(strip $(PROJECT_DIRECTORY)),)
$(error PROJECT_DIRECTORY must be defined when using the standard cpp makefile)
endif
PROJECT_MAIN_SRCS ?= 

# 'all' as first target
all: debug release checking

# =============================================================================
# INITIALISATION
# =============================================================================

# Include a local configuration file if the user created one.
-include $(DDSTAR_TOP_LEVEL_DIR)/local-config.mk

DOXYGEN ?= doxygen
AR ?= ar
PYTHON ?= python

# Useful version information. If the project is not under Git, use mock values.
ifeq ($(wildcard $(PROJECT_DIRECTORY)/.git)$(wildcard $(DDSTAR_TOP_LEVEL_DIR)/.git),)
PROJECT_ACTIVE_BRANCH := not-in-git
PROJECT_HEAD_COMMIT_HASH := 0000000000000000000000000000000000000000
PROJECT_NUMBER_COMMITS := 0
else
PROJECT_ACTIVE_BRANCH := $(shell cd $(PROJECT_DIRECTORY); git rev-parse --abbrev-ref HEAD)
PROJECT_HEAD_COMMIT_HASH := $(shell cd $(PROJECT_DIRECTORY); git rev-parse HEAD)
PROJECT_NUMBER_COMMITS := $(shell cd $(PROJECT_DIRECTORY); git rev-list --count master..)
endif
PROJECT_VERSION_DEFS := -DVERSION_ACTIVE_BRANCH="\"$(PROJECT_ACTIVE_BRANCH)\"" -DVERSION_HEAD_COMMIT_HASH="\"$(PROJECT_HEAD_COMMIT_HASH)\"" -DVERSION_NUMBER_COMMITS=$(PROJECT_NUMBER_COMMITS)

# Include flags from dependencies
DDSTAR_DEPS_INCLUDE_FLAGS := $(patsubst %,-I$(DDSTAR_DEPS_DIR)/%/include,$(DDSTAR_ACTUAL_DEPS))

ifeq ($(strip $(PROJECT_NAME)),core)
INCLUDE_FLAGS := -I. -I$(DDSTAR_CORE_DIR)/include $(DDSTAR_DEPS_INCLUDE_FLAGS)
LIBRARY_FLAGS_DEBUG :=
LIBRARY_FLAGS_CHECKING :=
LIBRARY_FLAGS_RELEASE :=
else
INCLUDE_FLAGS := -I. -I$(PROJECT_DIRECTORY)/include -I$(DDSTAR_TOP_LEVEL_DIR)/product/include $(DDSTAR_DEPS_INCLUDE_FLAGS)
LIBRARY_FLAGS_DEBUG := -L$(DDSTAR_TOP_LEVEL_DIR)/product/lib/debug -lcore
LIBRARY_FLAGS_CHECKING := -L$(DDSTAR_TOP_LEVEL_DIR)/product/lib/checking -lcore
LIBRARY_FLAGS_RELEASE := -L$(DDSTAR_TOP_LEVEL_DIR)/product/lib -lcore
endif

FLAGS_FOR_ALL := -Wall -Werror
CFLAGS_DEBUG := $(FLAGS_FOR_ALL) -O0 -g -DASSERTS=1 -DDEBUG=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
CXXFLAGS_DEBUG := $(FLAGS_FOR_ALL) -std=c++11 -pthread -O0 -g -DASSERTS=1 -DDEBUG=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
LDFLAGS_DEBUG := -pthread $(LIBRARY_FLAGS_DEBUG)
CFLAGS_RELEASE := $(FLAGS_FOR_ALL) -O2 -DNDEBUG=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
CXXFLAGS_RELEASE := $(FLAGS_FOR_ALL) -std=c++11 -pthread -O2 -DNDEBUG=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
LDFLAGS_RELEASE := -pthread $(LIBRARY_FLAGS_RELEASE)
CFLAGS_CHECKING := $(FLAGS_FOR_ALL) -O2 -g -DASSERTS=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
CXXFLAGS_CHECKING := $(FLAGS_FOR_ALL) -std=c++11 -pthread -O2 -g -DASSERTS=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
LDFLAGS_CHECKING := -pthread $(LIBRARY_FLAGS_CHECKING)

ALL_INCLUDES := $(wildcard $(PROJECT_DIRECTORY)/include/*.h) \
                $(wildcard $(PROJECT_DIRECTORY)/include/*/*.h) \
                $(wildcard $(PROJECT_DIRECTORY)/include/*/*/*.h) \
                $(wildcard $(PROJECT_DIRECTORY)/include/*/*/*/*.h) \
                $(wildcard $(PROJECT_DIRECTORY)/include/*/*/*/*/*.h) \
                $(wildcard $(PROJECT_DIRECTORY)/include/*/*/*/*/*/*.h) \
                $(wildcard $(PROJECT_DIRECTORY)/include/*/*/*/*/*/*/*.h)

CSRCS := $(wildcard $(PROJECT_DIRECTORY)/src/*.c) \
         $(wildcard $(PROJECT_DIRECTORY)/src/*/*.c) \
         $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*.c) \
         $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*/*.c) \
         $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*/*/*.c) \
         $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*/*/*/*.c) \
         $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*/*/*/*/*.c)

CPPSRCS := $(wildcard $(PROJECT_DIRECTORY)/src/*.cpp) \
           $(wildcard $(PROJECT_DIRECTORY)/src/*/*.cpp) \
           $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*.cpp) \
           $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*/*.cpp) \
           $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*/*/*.cpp) \
           $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*/*/*/*.cpp) \
           $(wildcard $(PROJECT_DIRECTORY)/src/*/*/*/*/*/*/*.cpp)

# If we have cpp sources use the compiler driver as the linker
ifneq ($(strip $(CPPSRCS)),)
LD = $(CXX)
endif

# Objects
COBJS_DEBUG = $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/debug/%.o,$(CSRCS))
CPPOBJS_DEBUG = $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/debug/%.opp,$(CPPSRCS))
COBJS_RELEASE = $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/release/%.o,$(CSRCS))
CPPOBJS_RELEASE = $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/release/%.opp,$(CPPSRCS))
COBJS_CHECKING = $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/checking/%.o,$(CSRCS))
CPPOBJS_CHECKING = $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/checking/%.opp,$(CPPSRCS))

MAINOBJS_DEBUG := $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/debug/%.opp,$(realpath $(PROJECT_MAIN_SRCS)))
MAINOBJS_RELEASE := $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/release/%.opp,$(realpath $(PROJECT_MAIN_SRCS)))
MAINOBJS_CHECKING := $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/checking/%.opp,$(realpath $(PROJECT_MAIN_SRCS)))

LIBOBJS_DEBUG = $(filter-out $(MAINOBJS_DEBUG),$(CPPOBJS_DEBUG) $(COBJS_DEBUG))
LIBOBJS_RELEASE = $(filter-out $(MAINOBJS_RELEASE),$(CPPOBJS_RELEASE) $(COBJS_RELEASE))
LIBOBJS_CHECKING = $(filter-out $(MAINOBJS_CHECKING),$(CPPOBJS_CHECKING) $(COBJS_CHECKING))

# Dependencies
CDEPS_DEBUG = $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/debug/%.d,$(CSRCS))
CPPDEPS_DEBUG = $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/debug/%.dpp,$(CPPSRCS))
CDEPS_RELEASE = $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/release/%.d,$(CSRCS))
CPPDEPS_RELEASE = $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/release/%.dpp,$(CPPSRCS))
CDEPS_CHECKING = $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/checking/%.d,$(CSRCS))
CPPDEPS_CHECKING = $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/checking/%.dpp,$(CPPSRCS))
dep_file_include_line = -include $(1)
$(foreach depfile,$(CDEPS_DEBUG) $(CPPDEPS_DEBUG),$(eval $(call dep_file_include_line,$(depfile))))
$(foreach depfile,$(CDEPS_RELEASE) $(CPPDEPS_RELEASE),$(eval $(call dep_file_include_line,$(depfile))))
$(foreach depfile,$(CDEPS_CHECKING) $(CPPDEPS_CHECKING),$(eval $(call dep_file_include_line,$(depfile))))

# Final targets
TARGET_LIBRARY := lib$(PROJECT_NAME).a
TARGET_PROGRAMS := $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,%,$(abspath $(PROJECT_MAIN_SRCS)))

# =============================================================================
# CLEANUP
# =============================================================================

clean: clean-build clean-doc clean-tests
	@echo "[$(PROJECT_NAME)] Cleaned."

clean-build: clean-debug clean-release clean-checking

clean-debug:
	rm -fr $(PROJECT_DIRECTORY)/build/lib/debug
	rm -fr $(PROJECT_DIRECTORY)/build/bin/debug
	rm -fr $(PROJECT_DIRECTORY)/build/obj/debug

clean-release:
	rm -fr $(PROJECT_DIRECTORY)/build/lib/release
	rm -fr $(PROJECT_DIRECTORY)/build/bin/release
	rm -fr $(PROJECT_DIRECTORY)/build/obj/release

clean-checking:
	rm -fr $(PROJECT_DIRECTORY)/build/lib/checking
	rm -fr $(PROJECT_DIRECTORY)/build/bin/checking
	rm -fr $(PROJECT_DIRECTORY)/build/obj/checking

clean-doc:
	rm -fr $(PROJECT_DIRECTORY)/build/doc/*

clean-tests:
	rm -fr $(PROJECT_DIRECTORY)/build/test/unit
	rm -fr $(PROJECT_DIRECTORY)/build/test/system

# =============================================================================
# DEBUG BUILD
# =============================================================================

DEBUG_PROGRAMS = $(patsubst %,$(PROJECT_DIRECTORY)/build/bin/debug/%,$(TARGET_PROGRAMS))
debug: $(PROJECT_DIRECTORY)/build/lib/debug/$(TARGET_LIBRARY) $(DEBUG_PROGRAMS)

$(PROJECT_DIRECTORY)/build/lib/debug/$(TARGET_LIBRARY): $(LIBOBJS_DEBUG)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Creating static library $@ for Debug..."
	@$(AR) rcs $@ $^

$(PROJECT_DIRECTORY)/build/bin/debug/%: $(PROJECT_DIRECTORY)/build/obj/debug/%.opp $(PROJECT_DIRECTORY)/build/lib/debug/$(TARGET_LIBRARY)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Linking executable $@ for Debug..."
	@$(LD) $^ $(LDFLAGS_DEBUG) -o $@

# Debug objs production
$(PROJECT_DIRECTORY)/build/obj/debug/%.o: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Debug..."
	@$(CC) -c $(CFLAGS_DEBUG) $< -o $@

$(PROJECT_DIRECTORY)/build/obj/debug/%.opp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Debug..."
	@$(CXX) -c $(CXXFLAGS_DEBUG) $< -o $@

# Dependency files, built according to the example in the GNU make manual.
$(PROJECT_DIRECTORY)/build/obj/debug/%.d: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CC) -MM $(CFLAGS_DEBUG) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/debug/%.o,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

$(PROJECT_DIRECTORY)/build/obj/debug/%.dpp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CXX) -MM $(CXXFLAGS_DEBUG) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/debug/%.opp,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.opp[ :]*,\1.opp $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

# =============================================================================
# RELEASE BUILD
# =============================================================================

RELEASE_PROGRAMS = $(patsubst %,$(PROJECT_DIRECTORY)/build/bin/release/%,$(TARGET_PROGRAMS))
release: $(PROJECT_DIRECTORY)/build/lib/release/$(TARGET_LIBRARY) $(RELEASE_PROGRAMS)

$(PROJECT_DIRECTORY)/build/lib/release/$(TARGET_LIBRARY): $(LIBOBJS_RELEASE)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Creating static library $@ for Release..."
	@$(AR) rcs $@ $^

$(PROJECT_DIRECTORY)/build/bin/release/%: $(PROJECT_DIRECTORY)/build/obj/release/%.opp $(PROJECT_DIRECTORY)/build/lib/release/$(TARGET_LIBRARY)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Linking executable $@ for Release..."
	@$(LD) $^ $(LDFLAGS_RELEASE) -o $@

# Release objs production
$(PROJECT_DIRECTORY)/build/obj/release/%.o: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Release..."
	@$(CC) -c $(CFLAGS_RELEASE) $< -o $@

$(PROJECT_DIRECTORY)/build/obj/release/%.opp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Release..."
	@$(CXX) -c $(CXXFLAGS_RELEASE) $< -o $@

# Dependency files, built according to the example in the GNU make manual.
$(PROJECT_DIRECTORY)/build/obj/release/%.d: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CC) -MM $(CFLAGS_RELEASE) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/release/%.o,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

$(PROJECT_DIRECTORY)/build/obj/release/%.dpp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CXX) -MM $(CXXFLAGS_RELEASE) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/release/%.opp,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.opp[ :]*,\1.opp $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

# =============================================================================
# CHECKING BUILD
# =============================================================================

CHECKING_PROGRAMS = $(patsubst %,$(PROJECT_DIRECTORY)/build/bin/checking/%,$(TARGET_PROGRAMS))
checking: $(PROJECT_DIRECTORY)/build/lib/checking/$(TARGET_LIBRARY) $(CHECKING_PROGRAMS)

$(PROJECT_DIRECTORY)/build/lib/checking/$(TARGET_LIBRARY): $(LIBOBJS_CHECKING)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Creating static library $@ for Checking..."
	@$(AR) rcs $@ $^

$(PROJECT_DIRECTORY)/build/bin/checking/%: $(PROJECT_DIRECTORY)/build/obj/checking/%.opp $(PROJECT_DIRECTORY)/build/lib/checking/$(TARGET_LIBRARY)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Linking executable $@ for Checking..."
	@$(LD) $^ $(LDFLAGS_CHECKING) -o $@

# Checking objs production
$(PROJECT_DIRECTORY)/build/obj/checking/%.o: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Checking..."
	@$(CC) -c $(CFLAGS_CHECKING) $< -o $@

$(PROJECT_DIRECTORY)/build/obj/checking/%.opp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Checking..."
	@$(CXX) -c $(CXXFLAGS_CHECKING) $< -o $@

# Dependency files, built according to the example in the GNU make manual.
$(PROJECT_DIRECTORY)/build/obj/checking/%.d: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CC) -MM $(CFLAGS_CHECKING) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/checking/%.o,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

$(PROJECT_DIRECTORY)/build/obj/checking/%.dpp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CXX) -MM $(CXXFLAGS_CHECKING) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/checking/%.opp,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.opp[ :]*,\1.opp $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

# =============================================================================
# TESTS
# =============================================================================

UNIT_TESTS_RESULTS_FILE := $(PROJECT_DIRECTORY)/build/test/unit/results/$(PROJECT_NAME).xml

SYSTEM_TESTS_RESULTS_FILE := $(PROJECT_DIRECTORY)/build/test/system/results/$(PROJECT_NAME).xml

tests: checking $(UNIT_TESTS_RESULTS_FILE) $(SYSTEM_TESTS_RESULTS_FILE)

# =============================================================================
# UNIT TESTS
# =============================================================================

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

# =============================================================================
# SYSTEM TESTS
# =============================================================================

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

# =============================================================================
# DOCUMENTATION
# =============================================================================

# Only generate documentation if we have doxygen
ifeq ($(findstring Doxygen,$(shell $(DOXYGEN) --help)),Doxygen)
docs: $(PROJECT_DIRECTORY)/build/doc/reference/index.html $(PROJECT_DIRECTORY)/build/doc/documentation/index.html
else
docs:
	@echo "[$(PROJECT_NAME)] No Doxygen - documentation is not generated."
endif

$(PROJECT_DIRECTORY)/build/doc/reference/index.html: $(ALL_INCLUDES) $(CSRCS) $(CPPSRCS)
	@echo "[$(PROJECT_NAME)] Generating source documentation with Doxygen..."
	@mkdir -p $(PROJECT_DIRECTORY)/build/doc
	@DDSTAR_DOX_PROJ_NAME=$(PROJECT_NAME) $(DOXYGEN) $(DDSTAR_TOP_LEVEL_DIR)/infra/doxy/reference-doxyfile

ALL_DOC_SOURCES := $(wildcard $(PROJECT_DIRECTORY)/doc/*.md) \
                   $(wildcard $(PROJECT_DIRECTORY)/doc/*/*.md) \
                   $(wildcard $(PROJECT_DIRECTORY)/doc/*/*/*.md) \
                   $(wildcard $(PROJECT_DIRECTORY)/doc/*/*/*/*.md) \
                   $(wildcard $(PROJECT_DIRECTORY)/doc/*/*/*/*/*.md) \
                   $(wildcard $(PROJECT_DIRECTORY)/doc/*/*/*/*/*/*.md) \
                   $(wildcard $(PROJECT_DIRECTORY)/doc/*/*/*/*/*/*/*.md) 

# Only generate additional documentation if required.
ifneq ($(strip $(ALL_DOC_SOURCES)),)
$(PROJECT_DIRECTORY)/build/doc/documentation/index.html: $(ALL_DOC_SOURCES)
	@echo "[$(PROJECT_NAME)] Generating additional documentation with Doxygen..."
	@mkdir -p $(PROJECT_DIRECTORY)/build/doc
	@DDSTAR_DOX_PROJ_NAME=$(PROJECT_NAME) $(DOXYGEN) $(DDSTAR_TOP_LEVEL_DIR)/infra/doxy/documentation-doxyfile
else
$(PROJECT_DIRECTORY)/build/doc/documentation/index.html:
	@echo "[$(PROJECT_NAME)] No additional documentation to generate..."
	@mkdir -p $(PROJECT_DIRECTORY)/build/doc/documentation
	@echo "<html><body>This project has no additional documentation.</body></html>" > $@
endif

# =============================================================================
# INSTALLATION
# =============================================================================

install: all makeproductdirs install-include install-docs install-test-results
	@echo "[$(PROJECT_NAME)] Installing libraries..."
	@cp $(PROJECT_DIRECTORY)/build/lib/release/* $(DDSTAR_TOP_LEVEL_DIR)/product/lib/
	@cp $(PROJECT_DIRECTORY)/build/lib/debug/* $(DDSTAR_TOP_LEVEL_DIR)/product/lib/debug/
	@cp $(PROJECT_DIRECTORY)/build/lib/checking/* $(DDSTAR_TOP_LEVEL_DIR)/product/lib/checking/
	@echo "[$(PROJECT_NAME)] Installing binaries..."
	@if [ -d $(PROJECT_DIRECTORY)/build/bin/release ]; then cp $(PROJECT_DIRECTORY)/build/bin/release/* $(DDSTAR_TOP_LEVEL_DIR)/product/bin/ ; fi
	@if [ -d $(PROJECT_DIRECTORY)/build/bin/debug ]; then cp $(PROJECT_DIRECTORY)/build/bin/debug/* $(DDSTAR_TOP_LEVEL_DIR)/product/bin/debug/ ; fi
	@if [ -d $(PROJECT_DIRECTORY)/build/bin/checking ]; then cp $(PROJECT_DIRECTORY)/build/bin/checking/* $(DDSTAR_TOP_LEVEL_DIR)/product/bin/checking/ ; fi
	@echo "[$(PROJECT_NAME)] Installed in $(DDSTAR_TOP_LEVEL_DIR)/product."

makeproductdirs:
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/bin
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/bin/debug
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/bin/checking
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/lib
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/lib/debug
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/lib/checking
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/include
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/doc/$(PROJECT_NAME)/reference
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/doc/$(PROJECT_NAME)/documentation
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/test-results/unit
	@mkdir -p $(DDSTAR_TOP_LEVEL_DIR)/product/test-results/system

install-include: makeproductdirs
	@echo "[$(PROJECT_NAME)] Installing include files..."
	@cp -r $(PROJECT_DIRECTORY)/include/* $(DDSTAR_TOP_LEVEL_DIR)/product/include/

# Only generate documentation if we have doxygen
ifeq ($(findstring Doxygen,$(shell $(DOXYGEN) --help)),Doxygen)
install-docs: docs makeproductdirs
	@echo "[$(PROJECT_NAME)] Installing documentation..."
	@cp -r $(PROJECT_DIRECTORY)/build/doc/reference/* $(DDSTAR_TOP_LEVEL_DIR)/product/doc/$(PROJECT_NAME)/reference/
	@cp -r $(PROJECT_DIRECTORY)/build/doc/documentation/* $(DDSTAR_TOP_LEVEL_DIR)/product/doc/$(PROJECT_NAME)/documentation/
else
install-docs:
	@echo "[$(PROJECT_NAME)] No Doxygen - documentation is not installed."
endif

install-test-results: tests makeproductdirs
	@echo "[$(PROJECT_NAME)] Installing test results..."
	@cp -r $(PROJECT_DIRECTORY)/build/test/unit/results/* $(DDSTAR_TOP_LEVEL_DIR)/product/test-results/unit/
	@cp -r $(PROJECT_DIRECTORY)/build/test/system/results/* $(DDSTAR_TOP_LEVEL_DIR)/product/test-results/system/