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

#
# TOP LEVEL MAKEFILE FOR DDSTAR CORE AND SATELLITE PROJECTS
#

# First of all obtain the top level DDSTAR directory.
DDSTAR_TOP_LEVEL_DIR := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))

include $(DDSTAR_TOP_LEVEL_DIR)/infra/make/dd-star-dirs-and-projects.mk

# Each subproject must support the same targets as the DDSTAR core.
DDSTAR_STANDARD_TARGETS := clean debug release checking all tests docs install

list-targets:
	@echo ""
	@echo "Please provide a target to make."
	@echo ""
	@echo "Each project (including the core) provides standard targets."
	@echo "Standard targets are: $(DDSTAR_STANDARD_TARGETS)"
	@echo "To invoke a target for a project, use 'make <project>-<target>'"
	@echo "For example, 'make core-install'"
	@echo ""
	@echo "If you make a project (e.g. 'make core') this is equivalent to"
	@echo "'make <project>-install' for the specified project."
	@echo ""
	@echo "You can also 'make everything' to build and install all projects."
	@echo "And 'make reset' to clean absolutely everything. Be careful!"
	@echo ""

# The following code creates on the fly targets for the top level, the core
# project and the satellite projects.

everything: core $(DDSTAR_ACTUAL_SATELLITES)

# Top level reset. This depends on cleaning every project, and zaps the product.
reset:
	rm -rf product

top_level_reset = reset: $(1)-clean
$(foreach project,core $(DDSTAR_ACTUAL_SATELLITES),$(eval $(call top_level_reset,$(project))))

# Top level targets. These have the name of each project and make install.
# Except for core itself, all projects are dependent on core having been
# installed.
core: core-install
top_level_target = $(1): core-install $(1)-install
$(foreach project,$(DDSTAR_ACTUAL_SATELLITES),$(eval $(call top_level_target,$(project))))

# Core targets. Deal with make 3.81 and >=3.82 (different syntax).
ifeq (3.81,$(firstword $(sort $(MAKE_VERSION) 3.81)))
define core_target_and_rule 
core-$(1):
	+$(MAKE) -C $$(DDSTAR_CORE_DIR) $(1) DDSTAR_TOP_LEVEL_DIR=$$(DDSTAR_TOP_LEVEL_DIR)
endef
else
define core_target_and_rule =
core-$(1):
	+$(MAKE) -C $$(DDSTAR_CORE_DIR) $(1) DDSTAR_TOP_LEVEL_DIR=$$(DDSTAR_TOP_LEVEL_DIR)
endef
endif
$(foreach target,$(DDSTAR_STANDARD_TARGETS),$(eval $(call core_target_and_rule,$(target))))

# Satellite project targets. 
# All targets except clean depend on core being installed.
# Deal with make 3.81 and >=3.82 (different syntax).
ifeq (3.81,$(firstword $(sort $(MAKE_VERSION) 3.81)))
define project_target_and_rule
$(1)-$(2): $(if $(findstring clean,$(2)),,core-install)
	+$(MAKE) -C $$(DDSTAR_SATELLITES_DIR)/$(1) $(2) DDSTAR_TOP_LEVEL_DIR=$$(DDSTAR_TOP_LEVEL_DIR)
endef
else
define project_target_and_rule =
$(1)-$(2): $(if $(findstring clean,$(2)),,core-install)
	+$(MAKE) -C $$(DDSTAR_SATELLITES_DIR)/$(1) $(2) DDSTAR_TOP_LEVEL_DIR=$$(DDSTAR_TOP_LEVEL_DIR)
endef
endif
$(foreach target,$(DDSTAR_STANDARD_TARGETS),$(foreach project,$(DDSTAR_ACTUAL_SATELLITES),$(eval $(call project_target_and_rule,$(project),$(target)))))
