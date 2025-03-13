#!/usr/bin/env bash
#
# dir_script.sh
#
# Recursively gathers the directory structure and outputs it as a Markdown file,
# focusing on user-written code while excluding dependencies and build artifacts.
# Now supports common languages (e.g. Go, JavaScript) and has updated configuration.
#
# Usage: Run this script from your project root.

################################################################################
# Configuration
################################################################################

PROJECT_ROOT="/app"  # Update this to your project's absolute path if necessary
OUTPUT_FILE="/app/.notes/directory_structure.md"  # Absolute path to output file
MAX_DEPTH=4          # Maximum depth to traverse
MAX_FILES_PER_DIR=15 # Maximum number of files to show per directory

# Directories to exclude
EXCLUDE_DIRS=(
  ".git" ".github"
  "node_modules" "_build" "deps" "rel"
  "assets/node_modules" "assets/build" "assets/vendor"
  "priv/static" "priv/repo/structure.sql"
  "test" "tests" "coverage" "cypress"
  "logs" "tmp" ".elixir_ls" ".vscode" ".idea" ".notes"
  "doc" "docs" "apidoc"
  "dist" "build" "out" "target" "bin" "obj"
)

# File patterns to exclude
EXCLUDE_FILE_PATTERNS=(
  "*.beam" "*.o" "*.so" "*.dll" "*.exe" "*.lock"
  "*.log" "*.tmp" "*.temp" "*.bak" "*.backup"
  "*.min.js" "*.min.css" "*.map" "*.chunk.js"
  "package-lock.json" "yarn.lock" "mix.lock"
  "*.gz" "*.zip" "*.tar" "*.rar" "*.7z"
  "*.png" "*.jpg" "*.jpeg" "*.gif" "*.svg" "*.ico"
  "*.ttf" "*.woff" "*.woff2" "*.eot"
)

# Directories to focus on (only these will be included)
FOCUS_DIRS=(
  "lib"
  "assets/js"
  "assets/css"
  "config"
  "src"
  ".notes"
)

# Files allowed at the root level (whitelist)
ROOT_ALLOWED_FILES=(
  "mix.exs"
  "README.md"
  ".formatter.exs"
  ".gitignore"
)

################################################################################
# Helper Functions
################################################################################

# Build an indent prefix
indent_prefix() {
  local indent="$1"
  local prefix=""
  for ((i=0; i<indent; i++)); do
    prefix+="    "
  done
  echo -n "$prefix"
}

# Check if a path should be excluded
should_exclude() {
  local path="$1"
  local rel_path="${path#$PROJECT_ROOT/}"  # Remove PROJECT_ROOT prefix
  local indent="$2"

  # At root level, only include whitelisted files
  if [[ $indent -eq 0 && -f "$path" ]]; then
    local basename
    basename=$(basename "$path")
    local allowed=0
    for allow_file in "${ROOT_ALLOWED_FILES[@]}"; do
      if [[ "$basename" == "$allow_file" ]]; then
        allowed=1
        break
      fi
    done
    [[ $allowed -eq 0 ]] && return 0
  fi

  # Exclude if not in focus directories
  local in_focus=0
  for focus in "${FOCUS_DIRS[@]}"; do
    if [[ "$rel_path" == "$focus" || "$rel_path" == "$focus/"* ]]; then
      in_focus=1
      break
    fi
  done
  [[ $in_focus -eq 0 ]] && return 0

  # Exclude based on EXCLUDE_DIRS
  for exclude in "${EXCLUDE_DIRS[@]}"; do
    if [[ "$rel_path" == "$exclude" || "$rel_path" == "$exclude/"* ]]; then
      return 0
    fi
  done

  # For files, check pattern exclusions
  if [[ -f "$path" ]]; then
    for pattern in "${EXCLUDE_FILE_PATTERNS[@]}"; do
      if [[ "$path" == *$pattern ]]; then
        return 0
      fi
    done
  fi

  return 1
}

# Return an icon based on file extension
get_file_icon() {
  local file="$1"
  local extension="${file##*.}"
  case "$extension" in
    ex|exs)      echo "🟣" ;;  # Elixir
    eex|heex)    echo "🟪" ;;  # Elixir templates
    js|jsx)      echo "🟨" ;;  # JavaScript
    ts|tsx)      echo "🔵" ;;  # TypeScript
    go)          echo "🐹" ;;  # Go files
    css|scss)    echo "🎨" ;;  # Stylesheets
    json)        echo "📋" ;;  # JSON
    md)          echo "📝" ;;  # Markdown
    html|htm)    echo "🌐" ;;  # HTML
    sql)         echo "💾" ;;  # SQL
    sh|bash)     echo "🐚" ;;  # Shell scripts
    yml|yaml)    echo "⚙️" ;;  # YAML
    *)           echo "📄" ;;  # Other files
  esac
}

# Return an icon for directories
get_dir_icon() {
  local dir="$1"
  local basename
  basename=$(basename "$dir")
  case "$basename" in
    lib)         echo "📚" ;;  # Library code
    assets)      echo "🎭" ;;  # Frontend assets
    config)      echo "⚙️" ;;  # Configuration
    scripts)     echo "📜" ;;  # Scripts
    migrations)  echo "🔄" ;;  # Migrations
    templates)   echo "📋" ;;  # Templates
    controllers) echo "🎮" ;;  # Controllers
    models)      echo "💎" ;;  # Models
    views)       echo "👁️" ;;  # Views
    components)  echo "🧩" ;;  # Components
    hooks)       echo "🪝" ;;  # Hooks
    contexts)    echo "📦" ;;  # Contexts
    schemas)     echo "🗄️" ;;  # Schemas
    .notes)      echo "📔" ;;  # Notes
    js)          echo "🟨" ;;  # JavaScript directory
    css)         echo "🎨" ;;  # CSS directory
    api)         echo "🔌" ;;  # API directory
    *)           echo "📁" ;;  # Other directories
  esac
}

# Recursively build a Markdown-formatted directory structure
get_formatted_directory() {
  local path="$1"
  local indent="${2:-0}"
  local max_depth="${3:-$MAX_DEPTH}"

  if [[ $indent -ge $max_depth ]]; then
    local prefix
    prefix="$(indent_prefix "$indent")"
    echo "${prefix}- *(max depth reached)*"
    return
  fi

  local items=()
  IFS=$'\n' read -r -d '' -a items < <(ls -A "$path" 2>/dev/null && printf '\0')

  local dirs=()
  local files=()

  for item in "${items[@]}"; do
    [[ "$item" == "." || "$item" == ".." ]] && continue
    local fullpath="$path/$item"
    should_exclude "$fullpath" $indent && continue
    if [[ -d "$fullpath" ]]; then
      dirs+=("$item")
    else
      if [[ $indent -gt 0 ]]; then
        files+=("$item")
      fi
    fi
  done

  IFS=$'\n' sorted_dirs=($(sort <<<"${dirs[*]}"))
  IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))

  for item in "${sorted_dirs[@]}"; do
    local fullpath="$path/$item"
    local prefix
    prefix="$(indent_prefix "$indent")"
    local icon
    icon=$(get_dir_icon "$fullpath")
    echo "${prefix}- ${icon} **${item}/**"
    get_formatted_directory "$fullpath" $((indent + 1)) $max_depth
  done

  if [[ $indent -gt 0 ]]; then
    local file_count=0
    for item in "${sorted_files[@]}"; do
      if [[ $file_count -ge $MAX_FILES_PER_DIR ]]; then
        local prefix
        prefix="$(indent_prefix "$indent")"
        echo "${prefix}- *(and $(( ${#sorted_files[@]} - $MAX_FILES_PER_DIR )) more files)*"
        break
      fi
      local fullpath="$path/$item"
      local prefix
      prefix="$(indent_prefix "$indent")"
      local icon
      icon=$(get_file_icon "$item")
      echo "${prefix}- ${icon} ${item}"
      file_count=$((file_count + 1))
    done
  fi
}

# Generate the Markdown content for the directory structure
MARKDOWN_CONTENT="# Project Directory Structure

This document provides an overview of the project's directory structure, focusing on user-written code and excluding dependencies and build artifacts.

## Legend
- 🟣 Elixir (*.ex, *.exs)
- 🟪 Elixir Templates (*.eex, *.heex)
- 🟨 JavaScript (*.js, *.jsx)
- 🔵 TypeScript (*.ts, *.tsx)
- 🐹 Go (*.go)
- 🎨 Stylesheets (*.css, *.scss)
- 📋 JSON/Templates (*.json, templates)
- 📝 Markdown (*.md)
- 🌐 HTML (*.html, *.htm)
- 💾 SQL (*.sql)
- 🐚 Shell Scripts (*.sh, *.bash)
- ⚙️ Configuration (*.yml, *.yaml, config)
- 📄 Other Files

## Core Components

\`\`\`
$( get_formatted_directory "$PROJECT_ROOT" 0 $MAX_DEPTH )
\`\`\`

## Note
This structure was automatically generated and may not include all files. Directories and files that are typically not user code (build artifacts, dependencies, etc.) have been excluded. The structure is limited to a depth of $MAX_DEPTH levels and shows at most $MAX_FILES_PER_DIR files per directory.
"

mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "$MARKDOWN_CONTENT" > "$OUTPUT_FILE"
echo "Directory structure updated in $OUTPUT_FILE"
