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

/// \file Version.h
/// \brief Defines version-related functions.

#ifndef CORE_VERSION_H
#define CORE_VERSION_H

#include <string>
#include <stdint.h>

namespace core {

/// \brief Returns a full version string for the core project, suitable for
///        printing.
std::string getCoreVersionString();

/// \brief Returns the major version number for the core project.
///
/// This project uses Semantic Versioning to indicate compatibility. Semantic
/// Versioning is explained at http://semver.org and this function is part of
/// the required API that makes this project compliant with such versioning
/// system.
uint32_t getCoreMajorVersion();

/// \brief Returns the minor version number for the core project.
///
/// This project uses Semantic Versioning to indicate compatibility. Semantic
/// Versioning is explained at http://semver.org and this function is part of
/// the required API that makes this project compliant with such versioning
/// system.
uint32_t getCoreMinorVersion();

/// \brief Returns the patch version number for the core project.
///
/// This project uses Semantic Versioning to indicate compatibility. Semantic
/// Versioning is explained at http://semver.org and this function is part of
/// the required API that makes this project compliant with such versioning
/// system.
uint32_t getCorePatchVersion();

}

#endif // CORE_VERSION_H
