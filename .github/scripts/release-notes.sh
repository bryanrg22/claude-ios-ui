#!/usr/bin/env bash
# Prints the CHANGELOG.md section for one version, for use as the GitHub Release notes.
# Usage: .github/scripts/release-notes.sh 0.2.0
set -euo pipefail

version="${1:?usage: release-notes.sh <version>}"
changelog="$(cd "$(dirname "$0")/../.." && pwd)/CHANGELOG.md"

# Everything between this version's heading and the next heading (or the link references at the end of the file).
notes="$(awk -v heading="## [$version]" '
    index($0, heading) == 1 { found = 1; next }
    found && /^## \[/ { exit }
    found && /^\[[^]]+\]: / { exit }
    found { print }
' "$changelog" | sed -e '/./,$!d')"

if [ -z "$notes" ]; then
    echo "CHANGELOG.md has no entries under '## [$version]'." >&2
    exit 1
fi
printf '%s\n' "$notes"
