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

# =============================================================================
# DEBUG BUILD
# =============================================================================

DEBUG_PROGRAMS = $(patsubst %,$(PROJECT_DIRECTORY)/build/bin/debug/%,$(TARGET_PROGRAMS))
debug: $(PROJECT_DIRECTORY)/build/lib/debug/$(TARGET_LIBRARY) $(DEBUG_PROGRAMS)

$(PROJECT_DIRECTORY)/build/lib/debug/$(TARGET_LIBRARY): $(LIBOBJS_DEBUG)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Creating static library $@ for Debug..."
	@$(AR) rcs $@ $^

$(PROJECT_DIRECTORY)/build/bin/debug/%: $(PROJECT_DIRECTORY)/build/obj/debug/%.opp $(PROJECT_DIRECTORY)/build/lib/debug/$(TARGET_LIBRARY)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Linking executable $@ for Debug..."
	@$(LD) $^ $(LDFLAGS_DEBUG) -o $@

# Debug objs production
$(PROJECT_DIRECTORY)/build/obj/debug/%.o: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Debug..."
	@$(CC) -c $(CFLAGS_DEBUG) $< -o $@

$(PROJECT_DIRECTORY)/build/obj/debug/%.opp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Debug..."
	@$(CXX) -c $(CXXFLAGS_DEBUG) $< -o $@

# =============================================================================
# RELEASE BUILD
# =============================================================================

RELEASE_PROGRAMS = $(patsubst %,$(PROJECT_DIRECTORY)/build/bin/release/%,$(TARGET_PROGRAMS))
release: $(PROJECT_DIRECTORY)/build/lib/release/$(TARGET_LIBRARY) $(RELEASE_PROGRAMS)

$(PROJECT_DIRECTORY)/build/lib/release/$(TARGET_LIBRARY): $(LIBOBJS_RELEASE)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Creating static library $@ for Release..."
	@$(AR) rcs $@ $^

$(PROJECT_DIRECTORY)/build/bin/release/%: $(PROJECT_DIRECTORY)/build/obj/release/%.opp $(PROJECT_DIRECTORY)/build/lib/release/$(TARGET_LIBRARY)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Linking executable $@ for Release..."
	@$(LD) $^ $(LDFLAGS_RELEASE) -o $@

# Release objs production
$(PROJECT_DIRECTORY)/build/obj/release/%.o: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Release..."
	@$(CC) -c $(CFLAGS_RELEASE) $< -o $@

$(PROJECT_DIRECTORY)/build/obj/release/%.opp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Release..."
	@$(CXX) -c $(CXXFLAGS_RELEASE) $< -o $@

# =============================================================================
# CHECKING BUILD
# =============================================================================

CHECKING_PROGRAMS = $(patsubst %,$(PROJECT_DIRECTORY)/build/bin/checking/%,$(TARGET_PROGRAMS))
checking: $(PROJECT_DIRECTORY)/build/lib/checking/$(TARGET_LIBRARY) $(CHECKING_PROGRAMS)

$(PROJECT_DIRECTORY)/build/lib/checking/$(TARGET_LIBRARY): $(LIBOBJS_CHECKING)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Creating static library $@ for Checking..."
	@$(AR) rcs $@ $^

$(PROJECT_DIRECTORY)/build/bin/checking/%: $(PROJECT_DIRECTORY)/build/obj/checking/%.opp $(PROJECT_DIRECTORY)/build/lib/checking/$(TARGET_LIBRARY)
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Linking executable $@ for Checking..."
	@$(LD) $^ $(LDFLAGS_CHECKING) -o $@

# Checking objs production
$(PROJECT_DIRECTORY)/build/obj/checking/%.o: $(PROJECT_DIRECTORY)/src/%.c
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Checking..."
	@$(CC) -c $(CFLAGS_CHECKING) $< -o $@

$(PROJECT_DIRECTORY)/build/obj/checking/%.opp: $(PROJECT_DIRECTORY)/src/%.cpp
	@mkdir -p $(dir $@)
	@echo "[$(PROJECT_NAME)] Compiling $< for Checking..."
	@$(CXX) -c $(CXXFLAGS_CHECKING) $< -o $@

