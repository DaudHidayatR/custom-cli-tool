#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Source common utilities

# Version information
CLI_VERSION="1.0.0"
CLI_RELEASE_DATE="2025-05-08"

# Command name - configurable via environment variable
COMMAND_NAME="${COMMAND_NAME:-uii}"

# Colors for terminal output
if [ -t 1 ]; then
  COLOR_RED="\033[0;31m"
  COLOR_GREEN="\033[0;32m"
  COLOR_YELLOW="\033[0;33m"
  COLOR_BLUE="\033[0;34m"
  COLOR_RESET="\033[0m"
else
  COLOR_RED=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_BLUE=""
  COLOR_RESET=""
fi

# Logging functions
log_info() {
  echo "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

log_success() {
  echo "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

log_warning() {
  echo "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*" >&2
}

log_error() {
  echo "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

# Error handling
exit_with_error() {
  log_error "$1"
  exit "${2:-1}"
}

# Show version information
show_version() {
  echo "CLI version ${CLI_VERSION} (${CLI_RELEASE_DATE})"
  echo "Running on $(uname -s) $(uname -r)"
}

# Display help function
show_main_help() {
  cat << EOF
Usage: $COMMAND_NAME <command> [arguments]

Available commands:
  make <filename>     Create a new file with template header
  setup               Setup and configuration commands
  go new <nameproject> Create a new Go project from template
  --help, -h          Show this help message
  --version, -v       Show version information

For help on specific commands, run:
  $COMMAND_NAME <command> --help
EOF
}

# Check if a command exists in the PATH
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Validate that required commands are available
validate_requirements() {
  for cmd in "$@"; do
    if ! command_exists "$cmd"; then
      exit_with_error "Required command '$cmd' not found. Please install it and try again."
    fi
  done
}

# File operations
ensure_directory_exists() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir" || exit_with_error "Could not create directory: $dir"
    log_info "Created directory: $dir"
  fi
}

# If this script is being run directly, show an error
if [ "$(basename "$0")" = "common.sh" ]; then
  exit_with_error "This is a library file and should not be executed directly."
fi

# Load variables from .env file if it exists
load_env_file() {
  local env_file="$1"
  if [ -f "$env_file" ]; then
    log_info "Loading environment variables from $env_file"
    # Use grep to extract lines that aren't comments and process them
    while IFS= read -r line || [ -n "$line" ]; do
      # Skip empty lines and comments
      if [ -z "$line" ] || [[ "$line" =~ ^#.* ]]; then
        continue
      fi
      # Export the variable (making it available to the parent shell)
      eval "export $line"
    done < "$env_file"
  fi
}

# Detect the host's package manager: apt-get, dnf, yum, pacman, or apk
detect_pkg_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt-get"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v yum >/dev/null 2>&1; then
    echo "yum"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v apk >/dev/null 2>&1; then
    echo "apk"
  else
    echo ""
  fi
}
