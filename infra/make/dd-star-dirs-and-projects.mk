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

# Derived variables, generally useful.
DDSTAR_CORE_DIR := $(DDSTAR_TOP_LEVEL_DIR)/core
DDSTAR_DEPS_DIR := $(DDSTAR_TOP_LEVEL_DIR)/deps
DDSTAR_INFRA_DIR := $(DDSTAR_TOP_LEVEL_DIR)/infra
DDSTAR_SATELLITES_DIR := $(DDSTAR_TOP_LEVEL_DIR)/satellites

# DDSTAR satellite projects can be separate repositories. A developer may or may
# not have downloaded them. So we auto-discover which ones are present.
DDSTAR_ACTUAL_SATELLITES := $(filter-out readme.txt,$(notdir $(wildcard $(DDSTAR_SATELLITES_DIR)/*)))

# We also automatically discover dependency directories.
DDSTAR_ACTUAL_DEPS := $(filter-out readme.txt,$(notdir $(wildcard $(DDSTAR_DEPS_DIR)/*)))
