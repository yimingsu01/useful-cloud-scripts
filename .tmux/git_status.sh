#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  exit 0
fi

cd "$1" || exit 0

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
if [[ -n "$branch" && "$branch" != "HEAD" ]]; then
  echo "#[fg=colour10] $branch"
fi
