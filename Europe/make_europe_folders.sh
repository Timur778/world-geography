#!/usr/bin/env bash
set -euo pipefail

# Run this script INSIDE your Europe folder.

countries=(
  "Austria"
  "Andorra"
  "Albania"
  "Bulgaria"
  "Bosnia and Herzegovina"
  "Belgium"
  "Belarus"
  "Denmark"
  "Czech Republic"
  "Croatia"
  "Greece"
  "Germany"
  "Georgia"
  "France"
  "Finland"
  "Estonia"
  "Italy"
  "Ireland"
  "Iceland"
  "Hungary"
  "North Macedonia"
  "Luxembourg"
  "Lithuania"
  "Liechtenstein"
  "Latvia"
  "Kosovo"
  "Netherlands"
  "Montenegro"
  "Monaco"
  "Moldova"
  "Malta"
  "Norway"
  "Romania"
  "Portugal"
  "Poland"
  "Sweden"
  "Spain"
  "Slovenia"
  "Slovakia"
  "Serbia"
  "San Marino"
  "United Kingdom"
  "Ukraine"
  "Switzerland"
  "Scotland"
  "Greenland"
  "Vatican City"
  "Wales"
  "England"
)

for name in "${countries[@]}"; do
  folder="${name// /-}"                                 # spaces -> hyphens for folder
  file="$(echo "$folder" | tr '[:upper:]' '[:lower:]')"  # lowercase filename = folder lowercase

  mkdir -p "$folder"
  touch "$folder/$file.html" "$folder/$file.css"
done

echo "Done ✅ Created folders + empty .html/.css files."
