#!/bin/bash
set -e

source dev-container-features-test-lib

check "lazygit is on PATH" bash -c "command -v lazygit"
check "lazygit reports a version" lazygit --version
check "lazygit version output contains 'version'" bash -c "lazygit --version | grep -i version"

reportResults
