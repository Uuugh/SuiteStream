#!/usr/bin/env bash
# Copies the six ARB files in requirements/messages/ into the ScrumBoard's
# assets (scrum/scrumboard/assets/messages/). Nobody edits a copy by hand.
# Run it before every ScrumBoard build or test. The SCB-01.d test compares
# the copies with their sources.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$root/requirements/messages"
dst="$root/scrum/scrumboard/assets/messages"
mkdir -p "$dst"
for code in en es fr de pt nl; do
  cp "$src/app_$code.arb" "$dst/app_$code.arb"
done
echo "Copied 6 arb files to $dst"
