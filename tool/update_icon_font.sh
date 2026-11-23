#!/usr/bin/env bash
# Rebuilds assets/fonts/MaterialSymbolsRounded.ttf with every glyph used in lib/src/theme/suite_icons.dart.
# Run after adding an icon there (a web build fails with "Codepoint ... not found in font" otherwise).
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"
curl -sfL -o "$tmp/upstream.ttf" "https://raw.githubusercontent.com/google/material-design-icons/10ecc14790612ca8fd164e3f4ffe9c16fc50d5b7/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf"
fs="$(find "$(dirname "$(which flutter)")/cache/artifacts/engine" -name 'font-subset*' | head -1)"
grep -o "0x[0-9a-fA-F]\{4,5\}" lib/src/theme/suite_icons.dart | sed 's/0x//' | sort -u | while read -r h; do echo $((16#$h)); done | tr '\n' ' ' > "$tmp/cps.txt"
"$fs" "$tmp/new.ttf" "$tmp/upstream.ttf" < "$tmp/cps.txt" > /dev/null
cp "$tmp/new.ttf" assets/fonts/MaterialSymbolsRounded.ttf
echo "Icon font rebuilt with $(wc -w < "$tmp/cps.txt") glyphs."
