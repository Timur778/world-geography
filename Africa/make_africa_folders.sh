#!/usr/bin/env bash
set -euo pipefail

# Run this script INSIDE your Europe folder.

countries=(
  "Algeria"
  "Angola"
  "Benin"
  "Botswana"
  "Burkina-Faso"
  "Burundi"
  "Cameroon"
  "Cape-Verde"
  "Central-African-Republic"
  "Chad"
  "Comoros"
  "Cote-d-Ivoire"
  "Democratic-Republic-of-the-Congo"
  "Djibouti"
  "Egypt"
  "Equatorial-Guinea"
  "Eritrea"
  "Ethiopia"
  "Gabon"
  "Gambia"
  "Ghana"
  "Guinea"
  "Guinea-Bissau"
  "Kenya"
  "Lesotho"
  "Liberia"
  "Libya"
  "Madagascar"
  "Malawi"
  "Mali"
  "Mauritania"
  "Mauritius"
  "Morocco"
  "Mozambique"
  "Namibia"
  "Niger"
  "Nigeria"
  "Republic-of-the-Congo"
  "Rwanda"
  "Sao-Tome-and-Principe"
  "Senegal"
  "Seychelles"
  "Sierra-Leone"
  "Somalia"
  "South-Africa"
  "South-Sudan"
  "Sudan"
  "Swaziland"
  "Tanzania"
  "Togo"
  "Tunisia"
  "Uganda"
  "Zambia"
  "Zimbabwe"
)

for name in "${countries[@]}"; do
  folder="${name// /-}"                                 # spaces -> hyphens for folder
  file="$(echo "$folder" | tr '[:upper:]' '[:lower:]')"  # lowercase filename = folder lowercase

  mkdir -p "$folder"
  touch "$folder/$file.html" "$folder/$file.css"
done

echo "Done ✅ Created folders + empty .html/.css files."
