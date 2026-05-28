#!/bin/bash
set -e

source dev-container-features-test-lib

check "tmux is on PATH" bash -c "command -v tmux"
check "tmux reports a version" tmux -V
check "tmux version matches expected format" bash -c "tmux -V | grep -E '^tmux [0-9]+\.[0-9]+'"

reportResults
