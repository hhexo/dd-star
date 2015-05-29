//  Copyright 2015 Dario Domizioli
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

/// \file Version.cpp
/// \brief Defines version-related data and functions.

#include "core/Version.h"
#include <sstream>

namespace {

// These are the constants that represent the Semantic Version number for the
// project.

static constexpr uint32_t const MAJOR_VERSION = 0;

static constexpr uint32_t const MINOR_VERSION = 0;

static constexpr uint32_t const PATCH_VERSION = 0;


// These values come from the build system (passed with -D to the compiler).

static constexpr char const * const BRANCH_NAME = VERSION_ACTIVE_BRANCH;

static constexpr char const * const HEAD_COMMIT = VERSION_HEAD_COMMIT_HASH;

static constexpr uint32_t const NUMBER_COMMITS = VERSION_NUMBER_COMMITS;

}

namespace core {

std::string getCoreVersionString() {
    bool const branch_is_master = std::string(BRANCH_NAME) == "master";
    std::stringstream full_string;
    full_string << "Core " << MAJOR_VERSION << "." << MINOR_VERSION << "."
                << PATCH_VERSION;
    if(!branch_is_master) {
        full_string << "-c" << NUMBER_COMMITS;
    } 
    full_string << " (" << BRANCH_NAME << " " << HEAD_COMMIT << ")";
    return full_string.str();
}

uint32_t getCoreMajorVersion() {
    return MAJOR_VERSION;
}

uint32_t getCoreMinorVersion() {
    return MINOR_VERSION;
}

uint32_t getCorePatchVersion() {
    return PATCH_VERSION;
}

}
