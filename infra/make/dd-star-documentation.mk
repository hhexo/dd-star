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
