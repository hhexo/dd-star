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

# Check we have Python on the path.
ifneq ($(shell python --version 2>&1),)
PYTHON ?= python
else
$(error Missing prerequisite - Python must be on the path)
endif

# Check we have git on the path.
ifneq ($(shell git --version 2>&1),)
GIT ?= git
else
$(error Missing prerequisite - Git must be on the path)
endif

# Determine compiler. Prefer clang to gcc if it's available.
# Also we let the compiler driver identify the linker.
ifneq ($(shell clang --version),)
CC  := clang
CXX := clang++
LD  := clang++
else
ifneq ($(shell gcc --version),)
# Use g++
CC  := gcc
CXX := g++
LD  := g++
endif
endif 

# Archiver.
AR ?= ar

# Doxygen.
DOXYGEN ?= doxygen
