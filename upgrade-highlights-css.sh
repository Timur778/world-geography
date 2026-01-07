#!/usr/bin/env bash
set -euo pipefail

CSS_FILE="${1:-}"

if [[ -z "$CSS_FILE" ]]; then
  echo "❌ Usage:"
  echo '   bash upgrade-highlights-css.sh "Antarctica/antarctica-highlights.css"'
  exit 1
fi

if [[ ! -f "$CSS_FILE" ]]; then
  echo "❌ File not found: $CSS_FILE"
  exit 1
fi

echo "🧊 Upgrading highlights backgrounds in: $CSS_FILE"

# Backup once
[[ -f "$CSS_FILE.bak" ]] || cp "$CSS_FILE" "$CSS_FILE.bak"

perl -0777 -i -pe '
  s{
    background:\s*url\(\s*["'\'']?(\.\/Highlights\/[^"'\''\)]+?)\.(jpg|jpeg|png)\s*["'\'']?\s*\)
    \s*center\s*\/\s*cover\s*no-repeat\s*;
  }{
    background-image: image-set(
      url("$1-900.webp") 1x,
      url("$1-1800.webp") 2x
    );
    background-position: center;
    background-size: cover;
    background-repeat: no-repeat;
  }gix;
' "$CSS_FILE"

echo "✅ Done"
echo "🧷 Backup saved as: $CSS_FILE.bak"
