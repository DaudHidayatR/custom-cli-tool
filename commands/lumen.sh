#!/bin/bash
#
# lumen — $COMMAND_NAME lumen command for Lumen project initialization.
#
# Usage:
#   $COMMAND_NAME lumen new <nameproject>    Create a new Lumen project from template
#   $COMMAND_NAME lumen --help              Show help information
#

# Source common utilities
lumen_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$lumen_SCRIPT_DIR/../lib/common.sh"

# Get repository URL from environment variable (loaded from .env file)
LUMEN_TEMPLATE_REPO="${LUMEN_TEMPLATE_REPO}"

# Function to create a new lumen project from template
lumen_new_command() {
    local project_name="$1"

    # Validate input
    if [ -z "$project_name" ]; then
        log_error "Usage: $COMMAND_NAME lumen new <nameproject>"
        return 1
    fi

    # Validate template repo URL
    if [ -z "$LUMEN_TEMPLATE_REPO" ]; then
        log_error "No template repository URL defined. Please check your .env file."
        log_info "You can set LUMEN_TEMPLATE_REPO in your .env file or environment."
        return 1
    fi

    # Validate requirements
    validate_requirements git

    # Validate project name format (alphanumeric with hyphens and underscores)
    if ! [[ "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Invalid project name. Use only letters, numbers, hyphens, and underscores."
        return 1
    fi

    # Check if directory already exists
    if [ -d "$project_name" ]; then
        log_error "Directory '$project_name' already exists."
        return 1
    fi

    # Clone template repository
    log_info "Cloning template repository..."
    if ! git clone "$LUMEN_TEMPLATE_REPO" "$project_name"; then
        log_error "Failed to clone template repository."
        return 1
    fi

    # Change to project directory
    cd "$project_name" || exit_with_error "Failed to enter project directory."

    # Remove existing git repository
    log_info "Removing existing git repository..."
    rm -rf .git

    # Initialize new git repository
    log_info "Initializing new git repository..."
    if ! git init -b master; then
        exit_with_error "Failed to initialize git repository."
    fi

    # Create initial commit
    log_info "Creating initial commit..."
    git add .
    git commit -m "Initial commit"

    # Create and configure branches
    log_info "Setting up branches..."
    git branch -M master

    # Create staging branch
    git branch staging

    # Create develop branch
    git branch develop

    log_success "Successfully initialized lumen project '$project_name'!"
    log_info "Branches created: master, staging, develop"
    return 0
}

# Main lumen command handler
lumen_command() {
    local subcmd="${1:-}"
    shift || true

    case "$subcmd" in
        ""|--help|-h)
            cat << EOF
Usage: $COMMAND_NAME lumen <subcommand> [arguments]

Available subcommands:
  new <nameproject>    Create a new lumen project from template
  --help, -h          Show this help message

Example:
  $COMMAND_NAME lumen new my-project    Creates a new lumen project named "my-project"

Configuration:
  LUMEN_TEMPLATE_REPO    Environment variable to specify template repository in .env file
EOF
            return 0
            ;;
        new)
            lumen_new_command "$@"
            return $?
            ;;
        *)
            log_error "Unknown subcommand: $subcmd"
            log_info "Run '$COMMAND_NAME lumen --help' for usage information."
            return 1
            ;;
    esac
}

# If this script is being run directly (not sourced), run the command
if [ "$(basename "$0")" = "lumen.sh" ]; then
    lumen_command "$@"
    exit $?
fi
