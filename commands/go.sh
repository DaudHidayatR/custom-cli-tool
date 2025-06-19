#!/bin/bash
#
# go — $COMMAND_NAME go command for Go project initialization.
#
# Usage:
#   $COMMAND_NAME go new <nameproject>    Create a new Go project from template
#   $COMMAND_NAME go --help              Show help information
#

# Source common utilities
GO_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$GO_SCRIPT_DIR/../lib/common.sh"

# Get repository URL from environment variable (loaded from .env file)
GO_TEMPLATE_REPO="${GO_TEMPLATE_REPO}"

# Function to create a new Go project from template
go_new_command() {
    local project_name="$1"
    
    # Validate input
    if [ -z "$project_name" ]; then
        log_error "Usage: $COMMAND_NAME go new <nameproject>"
        return 1
    fi

    # Validate template repo URL
    if [ -z "$GO_TEMPLATE_REPO" ]; then
        log_error "No template repository URL defined. Please check your .env file."
        log_info "You can set GO_TEMPLATE_REPO in your .env file or environment."
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
    if ! git clone "$GO_TEMPLATE_REPO" "$project_name"; then
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
    
    log_success "Successfully initialized Go project '$project_name'!"
    log_info "Branches created: master, staging, develop"
    return 0
}

# Main go command handler
go_command() {
    local subcmd="${1:-}"
    shift || true
    
    case "$subcmd" in
        ""|--help|-h)
            cat << EOF
Usage: $COMMAND_NAME go <subcommand> [arguments]

Available subcommands:
  new <nameproject>    Create a new Go project from template
  --help, -h          Show this help message

Example:
  $COMMAND_NAME go new my-project    Creates a new Go project named "my-project"

Configuration:
  GO_TEMPLATE_REPO    Environment variable to specify template repository in .env file
EOF
            return 0
            ;;
        new)
            go_new_command "$@"
            return $?
            ;;
        *)
            log_error "Unknown subcommand: $subcmd"
            log_info "Run '$COMMAND_NAME go --help' for usage information."
            return 1
            ;;
    esac
}

# If this script is being run directly (not sourced), run the command
if [ "$(basename "$0")" = "go.sh" ]; then
    go_command "$@"
    exit $?
fi
