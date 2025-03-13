#!/usr/bin/env bash
#
# install_rules.sh
#
# This script clones the central repository containing Cursor rules, copies
# rule files from the "rules" subdirectory into the project's .cursor/rules directory,
# and then runs the dir_setup.sh script (located at the root of the cloned repo)
# to generate a directory structure file in your project.
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

# Enable nullglob to handle cases where no files match
shopt -s nullglob

# Create an array of rule files from the "rules" subdirectory (both .mdc and .md files)
rule_files=("$TMP_DIR/rules/"*.mdc "$TMP_DIR/rules/"*.md)

if [ ${#rule_files[@]} -eq 0 ]; then
  echo "Warning: No rule files found in the repository's 'rules' subdirectory."
else
  echo "Copying rule files to ${TARGET_DIR}..."
  cp "${rule_files[@]}" "$TARGET_DIR"/
fi

# Check if dir_setup.sh exists in the cloned repository root and is executable,
# then run it to generate the directory structure in your project.
if [[ -x "$TMP_DIR/dir_setup.sh" ]]; then
  echo "Running directory structure setup from the cloned repository..."
  # Change directory to the cloned repository temporarily so that dir_setup.sh uses its own logic.
  ( cd "$TMP_DIR" && ./dir_setup.sh )
else
  echo "Warning: dir_setup.sh not found or not executable in the cloned repository."
fi

# Clean up temporary directory
rm -rf "$TMP_DIR"

echo "Cursor rules have been installed in ${TARGET_DIR}."
