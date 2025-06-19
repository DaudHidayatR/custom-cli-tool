#!/bin/bash
#
# laravel — $COMMAND_NAME laravel command for Laravel project initialization.
#
# Usage:
#   $COMMAND_NAME laravel new <nameproject>    Create a new Laravel project from template
#   $COMMAND_NAME laravel --help              Show help information
#

# Source common utilities
laravel_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$laravel_SCRIPT_DIR/../lib/common.sh"

# Get repository URL from environment variable (loaded from .env file)
LARAVEL_TEMPLATE_REPO="${LARAVEL_TEMPLATE_REPO}"

# Function to create a new laravel project from template
laravel_new_command() {
    local project_name="$1"

    # Validate input
    if [ -z "$project_name" ]; then
        log_error "Usage: $COMMAND_NAME laravel new <nameproject>"
        return 1
    fi

    # Validate template repo URL
    if [ -z "$LARAVEL_TEMPLATE_REPO" ]; then
        log_error "No template repository URL defined. Please check your .env file."
        log_info "You can set LARAVEL_TEMPLATE_REPO in your .env file or environment."
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
    if ! git clone "$LARAVEL_TEMPLATE_REPO" "$project_name"; then
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

    log_success "Successfully initialized laravel project '$project_name'!"
    log_info "Branches created: master, staging, develop"
    return 0
}

# Main laravel command handler
laravel_command() {
    local subcmd="${1:-}"
    shift || true

    case "$subcmd" in
        ""|--help|-h)
            cat << EOF
Usage: $COMMAND_NAME laravel <subcommand> [arguments]

Available subcommands:
  new <nameproject>    Create a new laravel project from template
  --help, -h          Show this help message

Example:
  $COMMAND_NAME laravel new my-project    Creates a new laravel project named "my-project"

Configuration:
  LARAVEL_TEMPLATE_REPO    Environment variable to specify template repository in .env file
EOF
            return 0
            ;;
        new)
            laravel_new_command "$@"
            return $?
            ;;
        *)
            log_error "Unknown subcommand: $subcmd"
            log_info "Run '$COMMAND_NAME laravel --help' for usage information."
            return 1
            ;;
    esac
}

# If this script is being run directly (not sourced), run the command
if [ "$(basename "$0")" = "laravel.sh" ]; then
    laravel_command "$@"
    exit $?
fi
