#!/usr/bin/env bash
set -euo pipefail

# ---------- SETTINGS ----------
Q_BG=74        # background webp quality
Q_CARD=78      # highlight/card webp quality
FORCE=0        # 0 = skip if outputs exist, 1 = regenerate always

# Background sizes
M1=768
M2=1536
D1=1280
D2=2560

# Card/highlight sizes
C1=900
C2=1800

IM_CMD="magick"

# ---------- HELPERS ----------
need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Missing: $1"; exit 1; }; }

make_webp_bg() {
  local src="$1" out_base="$2"
  local out1="${out_base}-${M1}.webp"
  local out2="${out_base}-${M2}.webp"
  local out3="${out_base}-${D1}.webp"
  local out4="${out_base}-${D2}.webp"

  if [[ "$FORCE" -eq 0 && -f "$out1" && -f "$out2" && -f "$out3" && -f "$out4" ]]; then
    echo "↪️  skip (exists): $src"
    return
  fi

  echo "🖼️  BG -> $src"
  $IM_CMD "$src" -auto-orient -strip -resize "${M1}x" -quality "$Q_BG" -define webp:method=6 "$out1"
  $IM_CMD "$src" -auto-orient -strip -resize "${M2}x" -quality "$Q_BG" -define webp:method=6 "$out2"
  $IM_CMD "$src" -auto-orient -strip -resize "${D1}x" -quality "$Q_BG" -define webp:method=6 "$out3"
  $IM_CMD "$src" -auto-orient -strip -resize "${D2}x" -quality "$Q_BG" -define webp:method=6 "$out4"
}

make_webp_card() {
  local src="$1" out_base="$2"
  local out1="${out_base}-${C1}.webp"
  local out2="${out_base}-${C2}.webp"

  if [[ "$FORCE" -eq 0 && -f "$out1" && -f "$out2" ]]; then
    echo "↪️  skip (exists): $src"
    return
  fi

  echo "🧊 Card -> $src"
  $IM_CMD "$src" -auto-orient -strip -resize "${C1}x" -quality "$Q_CARD" -define webp:method=6 "$out1"
  $IM_CMD "$src" -auto-orient -strip -resize "${C2}x" -quality "$Q_CARD" -define webp:method=6 "$out2"
}

# ---------- START ----------
need_cmd "$IM_CMD"
echo "✅ ImageMagick OK"
echo "📦 Running in: $(pwd)"
echo

# ---------- ROOT BACKGROUNDS (project root) ----------
# Matches: Planet-Earth.*, background-image.*, and anything containing "bg" (case-insensitive)
for f in ./*.{jpg,jpeg,png}; do
  [[ -e "$f" ]] || continue
  base="$(basename "$f")"
  lower="$(echo "$base" | tr '[:upper:]' '[:lower:]')"

  case "$lower" in
    planet-earth.*|background-image.*|*bg.*)
      make_webp_bg "$f" "${f%.*}"
      ;;
  esac
done

# ---------- CONTINENTS ----------
for continent in */; do
  continent="${continent%/}"
  [[ -d "$continent" ]] || continue

  case "$continent" in
    assets|images|Highlights|.git|node_modules)
      continue
      ;;
  esac

  echo
  echo "🌍 Continent: $continent"

  # --- CONTINENT BACKGROUND in continent root ---
  # Catches common names:
  # Asia/AsiaBg.jpg, Asia/AsiaBG.jpg, Asia/asia-bg.png, Asia/bg.jpg, Asia/background.jpg, etc (case-insensitive contains bg)
  find "$continent" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 \
  | while IFS= read -r -d '' img; do
      fname="$(basename "$img")"
      lower="$(echo "$fname" | tr '[:upper:]' '[:lower:]')"

      # Treat as continent background if it contains "bg" OR is named "background-*" / "background.*"
      if [[ "$lower" == *bg* || "$lower" == background* ]]; then
        make_webp_bg "$img" "${img%.*}"
      fi
    done

  # --- HIGHLIGHTS (cards) ---
  if [[ -d "$continent/Highlights" ]]; then
    find "$continent/Highlights" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 \
    | while IFS= read -r -d '' img; do
        make_webp_card "$img" "${img%.*}"
      done
  fi

  # --- COUNTRIES (folder name == image name) ---
  find "$continent" -mindepth 1 -maxdepth 1 -type d -print0 \
  | while IFS= read -r -d '' country_dir; do
      country="$(basename "$country_dir")"
      [[ "$country" == "Highlights" ]] && continue

      src=""
      for ext in jpg jpeg png; do
        if [[ -f "$country_dir/$country.$ext" ]]; then
          src="$country_dir/$country.$ext"
          break
        fi
      done

      if [[ -z "$src" ]]; then
        echo "⚠️  No matching image for: $country_dir (expected $country.jpg/.png)"
        continue
      fi

      make_webp_bg "$src" "$country_dir/$country"
    done
done

echo
echo "Done ✅ WebP variants generated in-place."
