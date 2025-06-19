# CLI - Command Line Interface for Initialization

A command-line utility for project initialization and development environment setup.

## Overview

This versatile command-line tool is designed to streamline development workflows. It provides functionality for:

- Creating new projects from standardized templates (Go, Laravel, Lumen).
- Creating new files with standardized template headers.
- Setting up and configuring development environments.
- Installing various programming languages and frameworks.

This tool aims to improve consistency and efficiency in development tasks across projects.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/DaudHidayatR/custom-cli-tool.git
    ```
    
    ```bash
    cd custom-cli-tool
    ```

2.  **Make the command script executable:**
    ```bash
    chmod +x uii
    ```

3.  **Optional: Add to your PATH**
    To make the command accessible from anywhere, add the project directory to your shell's `PATH`.

    From the project's root directory, run the command that corresponds to your shell:

    *   **For Bash:**
        ```bash
        echo 'export PATH="'$(pwd)':$PATH"' >> ~/.bashrc && source ~/.bashrc
        ```

    *   **For Zsh:**
        ```bash
        echo 'export PATH="'$(pwd)':$PATH"' >> ~/.zshrc && source ~/.zshrc
        ```
    You may need to restart your terminal for the changes to take effect. After this, you can run the command (e.g., `cli` or whatever you set in `.env`) from any directory.

## Configuration

You can customize the command name and template repositories by creating a `.env` file in the root of the project.

1.  **Copy the example file:**
    ```bash
    cp .env.example .env
    ```
2.  Edit the `.env` file to set your custom command name and repository URLs. The `COMMAND_NAME` in the `.env` file should match the name you used for your symbolic link if you created one.
    ```dotenv
    # Command Name Configuration
    COMMAND_NAME="uii"

    # Go template repository
    GO_TEMPLATE_REPO="your_go_template_repo_url"

    # Laravel template repository
    LARAVEL_TEMPLATE_REPO="your_laravel_template_repo_url"

    # Lumen template repository
    LUMEN_TEMPLATE_REPO="your_lumen_template_repo_url"
    ```

## Command Reference

### Basic Syntax

```
<command_name> <command> [arguments]
```
*(where `<command_name>` is what you defined in your `.env` file, defaulting to `cli`)*

### Available Commands

| Command | Description |
|---|---|
| `go new <name>` | Create a new Go project from a template. |
| `laravel new <name>` | Create a new Laravel project from a template. |
| `lumen new <name>` | Create a new Lumen project from a template. |
| `make <filename>` | Create a new file with a standard template header. |
| `setup` | Access setup and configuration commands. |
| `--help`, `-h` | Show help information. |
| `--version`, `-v` | Show version information. |

### Setup Commands

The `setup` command provides access to various installation and configuration subcommands:

| Subcommand | Description |
|---|---|
| `install` | Run basic installation. |
| `install:all` | Install all development tools. |
| `install:go` | Install Go programming language. |
| `install:java` | Install Java. |
| `install:php` | Install PHP. |
| `install:laravel` | Install Laravel framework. |
| `install:nodejs` | Install Node.js. |
| `install:npm` | Install npm package manager. |
| `install:angular` | Install Angular CLI. |
| `list-versions` | List available tool versions. |

## Usage Examples

Let's assume you have set `COMMAND_NAME="custom-cli"` in your `.env` file and created a symlink with the same name.

### Creating Projects from Templates

```bash
# Create a new Go project
uii go new my-go-project

# Create a new Laravel project
uii laravel new my-laravel-project

# Create a new Lumen project
uii lumen new my-lumen-project
```

### Creating Files with Template Headers

```bash
# Create a new Python file
uii make script.py

# Create a new JavaScript file
uii make app.js

# Create a new HTML file
uii make index.html
```

### Setting Up Development Environments

```bash
# Run basic installation
uii setup install

# Install all development tools
uii setup install:all

# Install specific programming languages/frameworks
uii setup install:nodejs
uii setup install:php
uii setup install:laravel
```

### Getting Help

You can access help information for any command by using the `--help` flag:

```bash
# General help
uii --help

# Help for specific commands
uii make --help
uii setup --help

# Help for setup subcommands
uii setup install --help
```

For additional assistance or to report issues, please contact the development team.
