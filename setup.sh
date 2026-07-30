#!/usr/bin/env bash
#
# setup.sh — renames this Flutter boilerplate project to a new app name.
#
# Usage: ./setup.sh MyApp
#
set -euo pipefail

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
  echo "Usage: ./setup.sh <NewAppName>"
  echo "Example: ./setup.sh MyAwesomeApp"
  exit 1
fi

# --self-test: copies the repo to a scratch directory, runs the rename
# end-to-end there, and verifies no leftover "boilerplate" strings remain
# (aside from this script's own source and the README, which intentionally
# keep the original project name). Does not touch the real working tree.
if [ "$1" = "--self-test" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  SCRATCH_DIR="$(mktemp -d)"
  trap 'rm -rf "$SCRATCH_DIR"' EXIT

  rsync -a \
    --exclude='.git' --exclude='build' --exclude='.dart_tool' \
    --exclude='.idea' --exclude='android/.gradle' --exclude='ios/Pods' \
    --exclude='.flutter-plugins*' --exclude='.cxx' \
    --exclude='ios/Flutter/Generated.xcconfig' \
    --exclude='ios/Flutter/flutter_export_environment.sh' \
    "$SCRIPT_DIR/" "$SCRATCH_DIR/"

  (cd "$SCRATCH_DIR" && bash setup.sh SelfTestApp)

  leftovers="$(
    grep -rniI "boilerplate" "$SCRATCH_DIR" \
      --exclude-dir=.git --exclude=setup.sh --exclude=README.md || true
  )"

  if [ -n "$leftovers" ]; then
    echo "Self-test FAILED: leftover 'boilerplate' strings found:"
    echo "$leftovers"
    exit 1
  fi

  echo "Self-test PASSED: no leftover 'boilerplate' strings after rename."
  exit 0
fi

NEW_NAME="$1"

if [[ ! "$NEW_NAME" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
  echo "Error: app name must be alphanumeric, PascalCase, no spaces (e.g. MyAwesomeApp)."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OLD_LOWER="boilerplate"
OLD_TITLE="Boilerplate"

# snake_case package name, e.g. MyAwesomeApp -> my_awesome_app
NEW_PACKAGE="$(echo "$NEW_NAME" | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]')"
# lowercase, no separators, for application/bundle IDs, e.g. MyAwesomeApp -> myawesomeapp
NEW_ID_SEGMENT="$(echo "$NEW_NAME" | tr '[:upper:]' '[:lower:]')"
NEW_TITLE="$NEW_NAME"

echo "Renaming project:"
echo "  package name (pubspec/imports): $OLD_LOWER -> $NEW_PACKAGE"
echo "  application/bundle id segment:  $OLD_LOWER -> $NEW_ID_SEGMENT"
echo "  display name / title:           $OLD_TITLE -> $NEW_TITLE"
echo

is_macos=false
if [[ "$(uname)" == "Darwin" ]]; then
  is_macos=true
fi

sed_inplace() {
  local pattern="$1"
  local file="$2"
  if $is_macos; then
    sed -i '' -E "$pattern" "$file"
  else
    sed -i -E "$pattern" "$file"
  fi
}

# Directories to exclude from the text-replacement scan.
EXCLUDE_DIRS=(
  ".git"
  "build"
  ".dart_tool"
  ".idea"
  "android/.gradle"
  "ios/Pods"
)

find_args=(".")
for dir in "${EXCLUDE_DIRS[@]}"; do
  find_args+=(-path "./$dir" -prune -o)
done

# 1) Replace all textual occurrences of the old package/id/title across
#    source, config, and CI files.
files_to_edit=()
while IFS= read -r -d '' f; do
  files_to_edit+=("$f")
done < <(
  find "${find_args[@]}" -type f \( \
      -name "*.dart" -o -name "*.yaml" -o -name "*.yml" -o \
      -name "*.gradle" -o -name "*.gradle.kts" -o -name "*.xml" -o \
      -name "*.plist" -o -name "*.pbxproj" -o -name "*.kt" -o \
      -name "*.properties" -o -name "*.entitlements" \
    \) -print0
)

for f in "${files_to_edit[@]}"; do
  grep -qi "$OLD_LOWER" "$f" 2>/dev/null || continue
  sed_inplace "s/${OLD_TITLE}/${NEW_TITLE}/g" "$f"
  sed_inplace "s/${OLD_LOWER}/${NEW_PACKAGE}/g" "$f"
done

# com.aks.boilerplate -> com.aks.<id_segment> (application/bundle identifiers
# must not contain underscores, so this is handled separately from the
# generic package-name substitution above).
for f in "${files_to_edit[@]}"; do
  grep -q "com\.aks\.${NEW_PACKAGE}" "$f" 2>/dev/null || continue
  sed_inplace "s/com\.aks\.${NEW_PACKAGE}/com.aks.${NEW_ID_SEGMENT}/g" "$f"
done

# 2) Move the Android Kotlin package folder to match the new applicationId.
OLD_KOTLIN_DIR="android/app/src/main/kotlin/com/aks/${OLD_LOWER}"
NEW_KOTLIN_DIR="android/app/src/main/kotlin/com/aks/${NEW_ID_SEGMENT}"
if [ -d "$OLD_KOTLIN_DIR" ]; then
  mkdir -p "$(dirname "$NEW_KOTLIN_DIR")"
  git mv "$OLD_KOTLIN_DIR" "$NEW_KOTLIN_DIR" 2>/dev/null || mv "$OLD_KOTLIN_DIR" "$NEW_KOTLIN_DIR"
fi

# 3) Make sure the script remains executable.
chmod +x "$SCRIPT_DIR/setup.sh"

echo "Done. '$OLD_LOWER'/'$OLD_TITLE' references have been renamed to '$NEW_PACKAGE'/'$NEW_TITLE'."
echo "Next steps: flutter pub get && flutter run"
