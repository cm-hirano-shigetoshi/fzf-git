#!/usr/bin/env bash
set -eu

if [ "$#" -ge 3 ]; then
    yml_dir=$1
    shift
    git diff --color=always $("$yml_dir/extract-hash.py" "$@") 2>/dev/null && echo "NO DIFFERENCE"
else
    hash=$("$1/extract-hash.py" "$2")
    if [[ -n "$hash" ]]; then
        git log -n 1 $hash
    fi
fi
