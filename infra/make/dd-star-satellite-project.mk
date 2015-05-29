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

PROJECT_MAKEFILE := $(realpath $(firstword $(MAKEFILE_LIST)))
PROJECT_DIRECTORY := $(patsubst %/Makefile,%,$(PROJECT_MAKEFILE))
PROJECT_NAME := $(notdir $(PROJECT_DIRECTORY))
include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-standard-cpp-project.mk
