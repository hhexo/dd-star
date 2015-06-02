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

# =============================================================================
# INPUT PARAMETERS
# =============================================================================

# Check we have defined DDSTAR_TOP_LEVEL_DIR before entering this file.
ifeq ($(strip $(DDSTAR_TOP_LEVEL_DIR)),)
$(error DDSTAR_TOP_LEVEL_DIR must be defined when running sub-makefiles. Try running make from the top level)
endif

# Check we have defined the input parameters
ifeq ($(strip $(PROJECT_NAME)),)
$(error PROJECT_NAME must be defined when using the standard makefile)
endif
ifeq ($(strip $(PROJECT_DIRECTORY)),)
$(error PROJECT_DIRECTORY must be defined when using the standard makefile)
endif
PROJECT_MAIN_SRCS ?= 

# =============================================================================
# DIRECTORIES DEFINITIONS
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-dirs-and-projects.mk

# =============================================================================
# TOOLS DEFINITIONS
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-tooling.mk

# =============================================================================
# VERSION INFORMATION
# =============================================================================

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

# =============================================================================
# COMPILATION FLAGS
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-compile-flags.mk

# =============================================================================
# OPTIONAL LOCAL CONFIGURATION
# =============================================================================

# Include a local configuration file if the user created one.
# This can override settings for tools, version, compile flags, and so on.
# YOU DO THIS AT YOUR OWN RISK!
-include $(DDSTAR_TOP_LEVEL_DIR)/local-config.mk


# =============================================================================
# DEFAULT TARGET
# =============================================================================

# 'all' is the default target
all: debug release checking


# =============================================================================
# SOURCES AND FINAL TARGET NAMES
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-sources-and-targets.mk

# =============================================================================
# SOURCE DEPENDENCIES CONSTRUCTION
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-source-dependencies-generation.mk

# =============================================================================
# CLEANUP
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-clean.mk

# =============================================================================
# BUILDS: DEBUG, CHECKING AND RELEASE
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-build.mk

# =============================================================================
# TESTS
# =============================================================================

UNIT_TESTS_RESULTS_FILE := $(PROJECT_DIRECTORY)/build/test/unit/results/$(PROJECT_NAME).xml

SYSTEM_TESTS_RESULTS_FILE := $(PROJECT_DIRECTORY)/build/test/system/results/$(PROJECT_NAME).xml

tests: checking $(UNIT_TESTS_RESULTS_FILE) $(SYSTEM_TESTS_RESULTS_FILE)

# =============================================================================
# UNIT TESTS
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-unit-tests.mk

# =============================================================================
# SYSTEM TESTS
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-system-tests.mk

# =============================================================================
# DOCUMENTATION
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-documentation.mk

# =============================================================================
# INSTALLATION
# =============================================================================

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-installation.mk
