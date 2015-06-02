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

# Cleanup targets.
clean: clean-build clean-doc clean-tests
	@echo "[$(PROJECT_NAME)] Cleaned."

clean-build: clean-debug clean-release clean-checking

clean-debug:
	rm -fr $(PROJECT_DIRECTORY)/build/lib/debug
	rm -fr $(PROJECT_DIRECTORY)/build/bin/debug
	rm -fr $(PROJECT_DIRECTORY)/build/obj/debug

clean-release:
	rm -fr $(PROJECT_DIRECTORY)/build/lib/release
	rm -fr $(PROJECT_DIRECTORY)/build/bin/release
	rm -fr $(PROJECT_DIRECTORY)/build/obj/release

clean-checking:
	rm -fr $(PROJECT_DIRECTORY)/build/lib/checking
	rm -fr $(PROJECT_DIRECTORY)/build/bin/checking
	rm -fr $(PROJECT_DIRECTORY)/build/obj/checking

clean-doc:
	rm -fr $(PROJECT_DIRECTORY)/build/doc/*

clean-tests:
	rm -fr $(PROJECT_DIRECTORY)/build/test/unit
	rm -fr $(PROJECT_DIRECTORY)/build/test/system
