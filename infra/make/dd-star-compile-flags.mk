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
 
# Definition flags for project version information.
PROJECT_VERSION_DEFS := -DVERSION_ACTIVE_BRANCH="\"$(PROJECT_ACTIVE_BRANCH)\"" -DVERSION_HEAD_COMMIT_HASH="\"$(PROJECT_HEAD_COMMIT_HASH)\"" -DVERSION_NUMBER_COMMITS=$(PROJECT_NUMBER_COMMITS)

# Include flags from dependencies.
DDSTAR_DEPS_INCLUDE_FLAGS := $(patsubst %,-I$(DDSTAR_DEPS_DIR)/%/include,$(DDSTAR_ACTUAL_DEPS))

# Include flags and link flags for core and satellite projects.
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

# Final compile and link flags for all configurations.
FLAGS_FOR_ALL := -Wall -Werror
CFLAGS_DEBUG := $(FLAGS_FOR_ALL) -O0 -g -DASSERTS=1 -DDEBUG=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
CXXFLAGS_DEBUG := $(FLAGS_FOR_ALL) -std=c++11 -pthread -O0 -g -DASSERTS=1 -DDEBUG=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
LDFLAGS_DEBUG := -Wl,-lpthread $(LIBRARY_FLAGS_DEBUG)
CFLAGS_RELEASE := $(FLAGS_FOR_ALL) -O2 -DNDEBUG=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
CXXFLAGS_RELEASE := $(FLAGS_FOR_ALL) -std=c++11 -pthread -O2 -DNDEBUG=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
LDFLAGS_RELEASE := -Wl,-lpthread $(LIBRARY_FLAGS_RELEASE)
CFLAGS_CHECKING := $(FLAGS_FOR_ALL) -O2 -g -DASSERTS=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
CXXFLAGS_CHECKING := $(FLAGS_FOR_ALL) -std=c++11 -pthread -O2 -g -DASSERTS=1 $(INCLUDE_FLAGS) $(PROJECT_VERSION_DEFS)
LDFLAGS_CHECKING := -Wl,-lpthread $(LIBRARY_FLAGS_CHECKING)
