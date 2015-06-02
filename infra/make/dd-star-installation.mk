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
