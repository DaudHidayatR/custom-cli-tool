#!/bin/bash
#
# make — $COMMAND_NAME make command for file creation.
#
# Usage:
#   $COMMAND_NAME make <filename>  (create a file with template)
#

# Source common utilities
MAKE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$MAKE_SCRIPT_DIR/../lib/common.sh"

# Function to create a new file with template
make_create_file() {
  local target="$1"
  
  if [ -z "$target" ]; then
    log_error "Usage: $COMMAND_NAME make <filename>"
    return 1
  fi
  
  # Create the file with some default content
  cat > "$target" << EOF
# =============================================================================
# File: '$target'
# Created on: $(date +"%Y-%m-%d %H:%M:%S")
# Description: 
# =============================================================================

EOF
  log_success "Created '$target' with template."
  return 0
}

# Main make command handler
make_command() {
  local target="$1"
  
  # If no arguments or help is requested, show usage
  if [ "$target" = "--help" ] || [ "$target" = "-h" ]; then
    log_error "Usage: $COMMAND_NAME make <filename>"
    log_error ""
    log_error "Create a new file with a standard template header."
    log_error ""
    return 1
  fi
  
  # Create the requested file
  make_create_file "$target"
  return $?
}

# If this script is being run directly (not sourced), run the command
if [ "$(basename "$0")" = "make.sh" ]; then
  make_command "$@"
  exit $?
fi
