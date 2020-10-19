#!/usr/bin/env bash
set -eu

readonly BRANCH=$(git rev-parse --abbrev-ref HEAD)

if echo "$1" | grep -q '^## '; then
    git diff --color=always "$BRANCH"
else
  readonly STATUS=$(echo "$1" | cut -c -2)
  readonly TARGET=$(echo "$1" | cut -c 4- | sed 's/^.\+ -> //')

  if [[ "$STATUS" = "??" ]]; then
    cat "$TARGET"
  elif [[ -e "$TARGET" ]]; then
    git diff --color=always "$BRANCH" "$TARGET"
  fi
fi

