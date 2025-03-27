#!/bin/bash -l

# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

# internal variables
__curDir="$( dirname "${BASH_SOURCE[0]}" )"
__workDir="$PWD"

# internal functions
function __main() {
    rsync -av --exclude='.git' --exclude='*.sh' "${__curDir}/" "${__workDir}/"
}

# main
__main "$@"
