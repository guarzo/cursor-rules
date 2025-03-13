#!/usr/bin/env bash
#
# install_rules.sh
#
# This script clones the central repository containing Cursor rules and copies
# them into the .cursor/rules directory of your project.
#
# Usage: Run this script from your project root.
#
# Note: Replace the RULES_REPO URL with your actual rules repository URL.

TARGET_DIR=".cursor/rules"
RULES_REPO="https://github.com/guarzo/cursor-rules.git"

echo "Cloning rules repository from ${RULES_REPO}..."
TMP_DIR=$(mktemp -d)
if ! git clone "$RULES_REPO" "$TMP_DIR"; then
  echo "Error: Failed to clone repository." >&2
  exit 1
fi

echo "Creating target directory ${TARGET_DIR} (if it doesn't exist)..."
mkdir -p "$TARGET_DIR"

echo "Copying rule files to ${TARGET_DIR}..."
cp "$TMP_DIR"/*.mdc "$TARGET_DIR"/

rm -rf "$TMP_DIR"

echo "Cursor rules have been installed in ${TARGET_DIR}."
