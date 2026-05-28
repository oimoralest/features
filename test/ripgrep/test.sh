#!/bin/bash
set -e

source dev-container-features-test-lib

check "rg is on PATH" bash -c "command -v rg"
check "rg reports a version" rg --version
check "rg version matches expected format" bash -c "rg --version | head -n1 | grep -E '^ripgrep [0-9]+\.[0-9]+'"
check "rg can perform a basic search" bash -c "echo 'hello world' | rg hello"

reportResults
