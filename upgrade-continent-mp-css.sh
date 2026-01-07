#!/usr/bin/env bash
set -euo pipefail

echo "🌍 Upgrading continent main-page CSS to ContinentBG-*.webp"

find . -type f -name "*-mp.css" -print0 | while IFS= read -r -d '' css; do
  dir="$(dirname "$css")"
  continent="$(basename "$dir")"

  case "$continent" in
    assets|images|Highlights|.git|node_modules)
      continue
      ;;
  esac

  echo "➡️  $css  → ${continent}BG-*.webp"

  # Backup once
  [[ -f "$css.bak" ]] || cp "$css" "$css.bak"

  perl -0777 -i -pe '
    my $c = $ENV{CONT};

    # Remove old background shorthand inside body::before
    s/(body::before\s*\{[^}]*?)\n\s*background:\s*url\([^)]+\)\s*center\s*\/\s*cover\s*no-repeat\s*;\s*/$1\n/si;

    # Remove existing image-set if present (clean reruns)
    s/(body::before\s*\{[^}]*?)\n\s*background-image:\s*image-set\([^)]+\);\s*/$1\n/si;

    # Insert new WebP image-set
    s/(body::before\s*\{\s*\n)/$1  background-position: center;\n  background-size: cover;\n  background-repeat: no-repeat;\n  background-image: image-set(\n    url(\"${c}BG-768.webp\") 1x,\n    url(\"${c}BG-1536.webp\") 2x\n  );\n/si;
  ' "$css" CONT="$continent"

  # Desktop override (add only once)
  if ! grep -q "@media (min-width: 900px)" "$css"; then
    cat >> "$css" <<EOF

@media (min-width: 900px){
  body::before{
    background-image: image-set(
      url("${continent}BG-1280.webp") 1x,
      url("${continent}BG-2560.webp") 2x
    );
  }
}
EOF
  fi

  echo "✅ Done: $css"
done

echo "🎉 All continent main pages updated"
