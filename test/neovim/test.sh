#!/bin/bash
set -e

source dev-container-features-test-lib

check "nvim is on PATH" bash -c "command -v nvim"
check "nvim reports a version" nvim --version
check "nvim version matches expected format" bash -c "nvim --version | head -n1 | grep -E '^NVIM v[0-9]+\.[0-9]+'"
check "nvim can run a no-op command" bash -c "nvim --headless +q"

reportResults
