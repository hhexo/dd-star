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

# Sources and headers
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

# Final targets
TARGET_LIBRARY := lib$(PROJECT_NAME).a
TARGET_PROGRAMS := $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,%,$(abspath $(PROJECT_MAIN_SRCS)))

