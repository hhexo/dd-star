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

# Target .d/.dpp files for dependency generation.
CDEPS_DEBUG = $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/debug/%.d,$(CSRCS))
CPPDEPS_DEBUG = $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/debug/%.dpp,$(CPPSRCS))
CDEPS_RELEASE = $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/release/%.d,$(CSRCS))
CPPDEPS_RELEASE = $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/release/%.dpp,$(CPPSRCS))
CDEPS_CHECKING = $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/checking/%.d,$(CSRCS))
CPPDEPS_CHECKING = $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/checking/%.dpp,$(CPPSRCS))

# Auto-include the .d/.dpp files. This forces their (re)generation if needed.
dep_file_include_line = -include $(1)
$(foreach depfile,$(CDEPS_DEBUG) $(CPPDEPS_DEBUG),$(eval $(call dep_file_include_line,$(depfile))))
$(foreach depfile,$(CDEPS_RELEASE) $(CPPDEPS_RELEASE),$(eval $(call dep_file_include_line,$(depfile))))
$(foreach depfile,$(CDEPS_CHECKING) $(CPPDEPS_CHECKING),$(eval $(call dep_file_include_line,$(depfile))))

# Targets to actually build the .d/.dpp files.
# Dependency files are built according to the example in the GNU make manual.

# Debug.
$(PROJECT_DIRECTORY)/build/obj/debug/%.d: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CC) -MM $(CFLAGS_DEBUG) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/debug/%.o,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

$(PROJECT_DIRECTORY)/build/obj/debug/%.dpp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CXX) -MM $(CXXFLAGS_DEBUG) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/debug/%.opp,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.opp[ :]*,\1.opp $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

# Release.
$(PROJECT_DIRECTORY)/build/obj/release/%.d: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CC) -MM $(CFLAGS_RELEASE) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/release/%.o,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

$(PROJECT_DIRECTORY)/build/obj/release/%.dpp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CXX) -MM $(CXXFLAGS_RELEASE) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/release/%.opp,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.opp[ :]*,\1.opp $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

# Checking.
$(PROJECT_DIRECTORY)/build/obj/checking/%.d: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CC) -MM $(CFLAGS_CHECKING) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.c,$(PROJECT_DIRECTORY)/build/obj/checking/%.o,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$

$(PROJECT_DIRECTORY)/build/obj/checking/%.dpp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@set -e; rm -f $@; \
        $(CXX) -MM $(CXXFLAGS_CHECKING) -MT $(patsubst $(PROJECT_DIRECTORY)/src/%.cpp,$(PROJECT_DIRECTORY)/build/obj/checking/%.opp,$<) $< -o $@.$$$$; \
        sed 's,\($*\)\.opp[ :]*,\1.opp $@ : ,g' < $@.$$$$ > $@; \
        rm -f $@.$$$$
