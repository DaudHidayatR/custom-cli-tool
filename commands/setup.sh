#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# setup — $COMMAND_NAME setup command with sub-commands.
# Usage:
#   $COMMAND_NAME setup                   (show help)
#   $COMMAND_NAME setup install           (run basic installation)
#   $COMMAND_NAME setup install:all       (install all development tools)
#   $COMMAND_NAME setup install:<tool>    (install specific tool)
#   $COMMAND_NAME setup list-versions     (list available tool versions)

# Determine script directory and source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$SCRIPT_DIR/../lib/common.sh"

# Available tools and their versions
AVAILABLE_GO_VERSIONS="1.16.15 1.17.13 1.18.10 1.19.13 1.20.14 1.21.9 1.22.2"
AVAILABLE_JAVA_VERSIONS="8 11 17 21"
AVAILABLE_PHP_VERSIONS="7.4 8.0 8.1 8.2 8.3"
AVAILABLE_NODEJS_VERSIONS="16.20.2 18.19.1 20.12.1 21.6.2 22.0.0"
AVAILABLE_ANGULAR_VERSIONS="8 9 10 11 12 13 14 15 16"

# Select version from a list
select_version() {
  local tool=$1 versions=$2
  local default_version=$(echo "$versions" | awk '{print $NF}')
  >&2 echo "Available $tool versions:"
  local i=1; IFS=$' \t\n'
  for version in $versions; do
    >&2 printf "  %d) %s\n" "$i" "$version"
    ((i++))
  done
  IFS=$'\n\t' >&2 printf "\nSelect $tool version [default: $default_version]: "
  local selection; read -r selection || true
  selection="${selection##*( )}"; selection="${selection%%*( )}"
  if [ -z "$selection" ]; then >&2 log_info "Using default version: $default_version"; echo "$default_version"; return 0; fi
  if [[ "$selection" =~ ^[0-9]+$ ]]; then
    local count=$(echo "$versions" | wc -w)
    if (( selection >=1 && selection <= count )); then
      local selected=$(echo "$versions" | awk -v idx="$selection" '{print $idx}')
      >&2 log_info "Selected version $selected (index $selection)"; echo "$selected"; return 0
    else
      >&2 log_warning "Invalid index: $selection. Using default: $default_version"; echo "$default_version"; return 0
    fi
  fi
  for version in $versions; do
    if [ "$selection" = "$version" ]; then >&2 log_info "Selected version $version (exact match)"; echo "$version"; return 0; fi
  done
  local matches=()
  for version in $versions; do
    if [[ "$version" == "$selection"* ]] || [[ "$version" == *"$selection"* ]]; then matches+=("$version"); fi
  done
  if [ "${#matches[@]}" -eq 1 ]; then
    >&2 log_info "Selected version ${matches[0]} (fuzzy match)"; echo "${matches[0]}"; return 0
  elif [ "${#matches[@]}" -gt 1 ]; then
    >&2 log_warning "Ambiguous selection '$selection'. Using default: $default_version"; echo "$default_version"; return 0
  else
    >&2 log_warning "No version found matching '$selection'. Using default: $default_version"; echo "$default_version"; return 0
  fi
}

# Determine package manager or Homebrew on macOS
detect_pm() {
  if [[ "$(uname)" == "Darwin" ]] && command_exists brew; then
    echo "brew"
  else
    detect_pkg_manager
  fi
}

# Install Go
install_go() {
  if command_exists go; then
    local current_version=$(go version | awk '{print $3}' | sed 's/go//')
    >&2 log_info "Go is already installed (version $current_version)"
    printf "Reinstall/upgrade? [y/N]: "; read -r answer; [[ ! "$answer" =~ ^[Yy]$ ]] && return 0
  fi
  local selected_version=$(select_version "Go" "$AVAILABLE_GO_VERSIONS")
  >&2 log_info "Installing Go version $selected_version..."
  local pm=$(detect_pm)
  case "$pm" in
    brew) brew install go@${selected_version} ;;
    apt-get) sudo apt-get update && sudo apt-get install -y golang-$selected_version-go ;;
    dnf) sudo dnf install -y golang ;;
    yum) sudo yum install -y golang ;;
    pacman) sudo pacman -Sy --noconfirm go ;;
    apk) sudo apk add go ;;
    *) >&2 log_error "Unsupported package manager: $pm"; return 1 ;;
  esac
  >&2 log_success "Go $selected_version installed successfully!"
}

# Install Java
install_java() {
  if command_exists java; then
    local current_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    >&2 log_info "Java is already installed (version $current_version)"
    printf "Reinstall/upgrade? [y/N]: "; read -r answer; [[ ! "$answer" =~ ^[Yy]$ ]] && return 0
  fi
  local selected_version=$(select_version "Java" "$AVAILABLE_JAVA_VERSIONS")
  >&2 log_info "Installing Java version $selected_version..."
  local pm=$(detect_pm)
  case "$pm" in
    brew) brew install openjdk@${selected_version} ;;
    apt-get) sudo apt-get update && sudo apt-get install -y openjdk-$selected_version-jdk ;;
    dnf) sudo dnf install -y java-$selected_version-openjdk-devel ;;
    yum) sudo yum install -y java-$selected_version-openjdk-devel ;;
    pacman) sudo pacman -Sy --noconfirm jdk-openjdk ;;
    apk) sudo apk add openjdk$selected_version ;;
    *) >&2 log_error "Unsupported package manager: $pm"; return 1 ;;
  esac
  >&2 log_success "Java $selected_version installed successfully!"
}

# Install PHP
install_php() {
  if command_exists php; then
    local current_version=$(php -v | head -1 | awk '{print $2}')
    >&2 log_info "PHP is already installed (version $current_version)"
    printf "Reinstall/upgrade? [y/N]: "; read -r answer; [[ ! "$answer" =~ ^[Yy]$ ]] && return 0
  fi
  local selected_version=$(select_version "PHP" "$AVAILABLE_PHP_VERSIONS")
  >&2 log_info "Installing PHP version $selected_version..."
  local pm=$(detect_pm)
  case "$pm" in
    brew) brew install php@${selected_version} ;;
    apt-get) sudo apt-get update && sudo apt-get install -y php$selected_version ;;
    dnf) sudo dnf install -y php-$selected_version ;;
    yum) sudo yum install -y php-$selected_version ;;
    pacman) sudo pacman -Sy --noconfirm php ;;
    apk) sudo apk add php$selected_version ;;
    *) >&2 log_error "Unsupported package manager: $pm"; return 1 ;;
  esac
  >&2 log_success "PHP $selected_version installed successfully!"
}

# Install Node.js
install_nodejs() {
  if command_exists node; then
    local current_version=$(node --version | sed 's/v//')
    >&2 log_info "Node.js is already installed (version $current_version)"
    printf "Reinstall/upgrade? [y/N]: "; read -r answer; [[ ! "$answer" =~ ^[Yy]$ ]] && return 0
  fi
  local selected_version=$(select_version "Node.js" "$AVAILABLE_NODEJS_VERSIONS")
  >&2 log_info "Installing Node.js version $selected_version..."
  local pm=$(detect_pm)
  case "$pm" in
    brew) brew install node@${selected_version} ;;
    apt-get)
      curl -fsSL https://deb.nodesource.com/setup_$selected_version.x | sudo -E bash -
      sudo apt-get install -y nodejs ;;
    pacman) sudo pacman -Sy --noconfirm nodejs npm ;;
    apk) sudo apk add nodejs npm ;;
    *) >&2 log_warning "Automatic install for Node.js on $pm not supported, consider using nvm." ;;
  esac
  >&2 log_success "Node.js $selected_version installed successfully!"
}

# Install npm
install_npm() {
  if ! command_exists node; then
    >&2 log_warning "npm requires Node.js, installing Node.js first..."
    install_nodejs
  fi
  if command_exists npm; then
    local current_version=$(npm --version)
    >&2 log_info "npm is already installed (version $current_version)"
    printf "Reinstall/upgrade? [y/N]: "; read -r answer; [[ ! "$answer" =~ ^[Yy]$ ]] && return 0
  fi
  local pm=$(detect_pm)
  >&2 log_info "Installing npm..."
  case "$pm" in
    brew) brew install npm ;;
    apt-get) sudo apt-get update && sudo apt-get install -y npm ;;
    pacman) sudo pacman -Sy --noconfirm npm ;;
    apk) sudo apk add npm ;;
    *) >&2 log_warning "npm usually comes with Node.js on $pm" ;;
  esac
  >&2 log_success "npm installed successfully!"
}

# Install Laravel installer via Composer
install_laravel() {
  if ! command_exists composer; then
    >&2 log_warning "Composer not found, installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
  fi
  >&2 log_info "Installing Laravel installer globally via Composer..."
  composer global require laravel/installer
  >&2 log_success "Laravel installer installed successfully!"
}

# Install Angular CLI via npm
install_angular() {
  if ! command_exists npm; then
    >&2 log_warning "npm not found, installing npm..."
    install_npm
  fi
  local selected_version=$(select_version "Angular CLI" "$AVAILABLE_ANGULAR_VERSIONS")
  >&2 log_info "Installing Angular CLI version $selected_version..."
  npm install -g @angular/uii@$selected_version
  >&2 log_success "Angular CLI $selected_version installed successfully!"
}

# List all available versions
list_versions() {
  echo "Go versions: $AVAILABLE_GO_VERSIONS"
  echo "Java versions: $AVAILABLE_JAVA_VERSIONS"
  echo "PHP versions: $AVAILABLE_PHP_VERSIONS"
  echo "Node.js versions: $AVAILABLE_NODEJS_VERSIONS"
  echo "Angular CLI versions: $AVAILABLE_ANGULAR_VERSIONS"
}

# Main command dispatcher
setup_command() {
  local subcmd=${1:-help}
  case "$subcmd" in
    ""|help)
      echo "Usage: $COMMAND_NAME setup [subcommand]"
      echo "Subcommands:"
      echo "  install           Install default set of tools"
      echo "  install:all       Install all tools"
      echo "  install:go        Install Go"
      echo "  install:java      Install Java"
      echo "  install:php       Install PHP"
      echo "  install:nodejs    Install Node.js"
      echo "  install:npm       Install npm"
      echo "  install:laravel   Install Laravel installer"
      echo "  install:angular   Install Angular CLI"
      echo "  list-versions     List available versions"
      ;;
    install|install:all)
      install_go
      install_java
      install_php
      install_nodejs
      install_npm
      install_laravel
      install_angular
      ;;
    install:go) install_go;;
    install:java) install_java;;
    install:php) install_php;;
    install:nodejs) install_nodejs;;
    install:npm) install_npm;;
    install:laravel) install_laravel;;
    install:angular) install_angular;;
    list-versions) list_versions;;
    *) >&2 log_error "Unknown subcommand: $subcmd"; exit 1;;
  esac
}

# Execute setup_command if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_command "$@"
  exit $?
fi
