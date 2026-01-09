#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash upgrade-country-bg-webp.sh
# Optional:
#   DRY_RUN=1 bash upgrade-country-bg-webp.sh

DRY_RUN="${DRY_RUN:-0}"

echo "🔎 Searching for country CSS files..."

# Find all css files inside continent folders (but skip top-level shared css if you want)
mapfile -t CSS_FILES < <(find . -type f -name "*.css" \
  ! -path "./.git/*" \
  ! -name "*.bak" \
  ! -name "*.min.css")

changed=0
skipped=0

for file in "${CSS_FILES[@]}"; do
  # Only process files that look like country CSS (they contain body::before and a .jpg background)
  if ! grep -q "body::before" "$file"; then
    continue
  fi

  # Extract the first jpg referenced inside body::before background: url("...jpg")
  jpg=$(perl -0777 -ne '
    if (/(body::before\s*\{.*?\bbg|body::before\s*\{.*?\bbackground)\s*:\s*url\(["'\'']([^"'\'']+\.jpe?g)["'\'']\)/is) {
      print $2;
    } elsif (/(body::before\s*\{.*?\bbackground)\s*:\s*url\(["'\'']([^"'\'']+\.jpe?g)["'\'']\)/is) {
      print $2;
    }
  ' "$file" || true)

  if [[ -z "${jpg:-}" ]]; then
    # Some of your files may already be webp or use a different structure — skip safely.
    continue
  fi

  base="${jpg%.*}"                 # Cameroon
  desktop_webp="${base}-1536.webp" # Cameroon-1536.webp
  mobile_webp="${base}-768.webp"   # Cameroon-768.webp

  # If it's already using -1536.webp, skip
  if grep -q "$desktop_webp" "$file"; then
    skipped=$((skipped+1))
    continue
  fi

  echo "✅ Updating: $file"
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "   - desktop: $jpg -> $desktop_webp"
    echo "   - mobile : $mobile_webp"
    continue
  fi

  cp "$file" "$file.bak"

  # 1) Replace the jpg used in body::before background url(...) with desktop webp
  perl -0777 -i -pe "
    s/(body::before\\s*\\{.*?\\bbackground\\s*:\\s*url\\([\"'])([^\"']+\\.jpe?g)([\"']\\)\\s*center\\s*\\/\\s*cover\\s*no-repeat;)/\$1$desktop_webp\$3/is;
  " "$file"

  # If the exact 'center / cover no-repeat' formatting differs, also do a simpler fallback replacement:
  perl -0777 -i -pe "
    s/(body::before\\s*\\{.*?\\bbackground\\s*:\\s*url\\([\"'])([^\"']+\\.jpe?g)([\"']\\))/\$1$desktop_webp\$3/is
    unless /$desktop_webp/s;
  " "$file"

  # 2) Mobile override:
  #    - If there's already @media (max-width: 768px) { ... body::before ... } then update it
  #    - Else inject body::before override inside existing @media
  #    - Else append a new @media block at the end

  if grep -q "@media (max-width: 768px)" "$file"; then
    # If body::before exists inside that media, update the url
    if perl -0777 -ne 'exit( /@media\s*\(max-width:\s*768px\)\s*\{.*?body::before\s*\{/s ? 0 : 1 )' "$file"; then
      perl -0777 -i -pe "
        s/(@media\\s*\\(max-width:\\s*768px\\)\\s*\\{.*?body::before\\s*\\{.*?\\bbackground(?:-image)?\\s*:\\s*url\\([\"'])([^\"']+?)([\"']\\))/\$1$mobile_webp\$3/s;
      " "$file"

      # If it doesn't have background-image but has full background, also adjust:
      perl -0777 -i -pe "
        s/(@media\\s*\\(max-width:\\s*768px\\)\\s*\\{.*?body::before\\s*\\{.*?\\bbackground\\s*:\\s*url\\([\"'])([^\"']+?)([\"']\\))/\$1$mobile_webp\$3/s;
      " "$file"
    else
      # Inject body::before override right after the @media opening brace
      perl -0777 -i -pe "
        s/(@media\\s*\\(max-width:\\s*768px\\)\\s*\\{)/\$1\\n  body::before{\\n    background-image: url(\\\"$mobile_webp\\\");\\n  }\\n/s
        unless /@media\\s*\\(max-width:\\s*768px\\)\\s*\\{.*?body::before\\s*\\{/s;
      " "$file"
    fi
  else
    cat >> "$file" <<EOF

/* ✅ auto-added: mobile background */
@media (max-width: 768px){
  body::before{
    background-image: url("$mobile_webp");
  }
}
EOF
  fi

  changed=$((changed+1))
done

echo ""
echo "Done."
echo "Changed files: $changed"
echo "Skipped files : $skipped"
echo "Backups      : *.css.bak"
