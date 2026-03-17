#!/bin/bash

# ==============================================================================
# Manage submodules in the understanding-series parent repository.
#
# Commands:
#   create <repo-name>   Create a new GitHub repo and add it as a submodule
#   update               Update all submodules to latest remote main
#   status               Show the sync status of every submodule
#
# Usage:
#   ./AUTOMATE-REPO-SUBMOD-SETUP.sh create <new-repo-name>
#   ./AUTOMATE-REPO-SUBMOD-SETUP.sh update
#   ./AUTOMATE-REPO-SUBMOD-SETUP.sh status
# ==============================================================================

set -e

# --- Configuration ---
GITHUB_USERNAME="adamkurth"
PARENT_REPO_DIR="$HOME/Documents/vscode/code/understanding-series"
# ---------------------

# --- Helper Functions for Colored Output ---
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_warn() {
    echo -e "\033[33m[WARN]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}
# -----------------------------------------

check_prerequisites() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI ('gh') is not installed. Please install it to continue."
    fi

    if [ ! -d "$PARENT_REPO_DIR" ]; then
        print_error "Parent repository directory not found at '$PARENT_REPO_DIR'."
    fi

    cd "$PARENT_REPO_DIR"
}

ensure_clean_main() {
    if [ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then
        print_error "You are not on the 'main' branch. Please switch to main before running."
    fi

    if ! git diff-index --quiet HEAD --; then
        print_error "You have uncommitted changes. Please commit or stash them before running."
    fi
    print_success "Parent repository is clean."
}

# ==============================================================================
# Command: create
# ==============================================================================
cmd_create() {
    local REPO_NAME=$1
    if [ -z "$REPO_NAME" ]; then
        print_error "Usage: $0 create <new-repo-name>"
    fi

    check_prerequisites
    ensure_clean_main

    # Create the GitHub repository (public, with a README)
    print_info "Creating new GitHub repository '$REPO_NAME'..."
    if ! gh repo create "$GITHUB_USERNAME/$REPO_NAME" --public --add-readme; then
        print_error "Failed to create GitHub repository. Check 'gh auth status'."
    fi
    print_success "Created repository on GitHub."

    # Add as a submodule with branch tracking
    print_info "Adding '$REPO_NAME' as a submodule..."
    git submodule add -b main "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git" "$REPO_NAME"

    # Commit and push
    print_info "Committing and pushing..."
    git add .gitmodules "$REPO_NAME"
    git commit -m "feat: Add $REPO_NAME submodule"
    git push

    print_success "Done! '$REPO_NAME' is now a submodule tracking 'main'."
}

# ==============================================================================
# Command: update
# ==============================================================================
cmd_update() {
    check_prerequisites

    print_info "Fetching latest for all submodules..."
    git submodule sync
    git submodule update --init --remote

    # Check if any submodule pointers changed
    if git diff --quiet; then
        print_success "All submodules are already up to date."
    else
        print_info "Submodule pointers updated. Committing..."
        git add -A
        git commit -m "fix: Update all submodule pointers to latest remote commits"
        print_success "Committed updated submodule pointers."
        print_info "Run 'git push' when ready to publish."
    fi
}

# ==============================================================================
# Command: status
# ==============================================================================
cmd_status() {
    check_prerequisites

    print_info "Submodule status (fetching remotes)...\n"

    git submodule foreach --quiet '
        git fetch origin 2>/dev/null
        LOCAL=$(git rev-parse HEAD)
        BRANCH=$(git config -f "$toplevel/.gitmodules" --get "submodule.$name.branch" 2>/dev/null || echo "main")
        REMOTE=$(git rev-parse "origin/$BRANCH" 2>/dev/null || echo "UNKNOWN")
        if [ "$LOCAL" = "$REMOTE" ]; then
            STATUS="\033[32mUP TO DATE\033[0m"
        else
            STATUS="\033[31mBEHIND\033[0m"
        fi
        printf "  %-45s %s\n" "$name" "$STATUS"
    '
}

# ==============================================================================
# Dispatch
# ==============================================================================
COMMAND=${1:-help}
shift 2>/dev/null || true

case "$COMMAND" in
    create)
        cmd_create "$@"
        ;;
    update)
        cmd_update
        ;;
    status)
        cmd_status
        ;;
    *)
        echo "Usage: $0 {create|update|status} [args]"
        echo ""
        echo "Commands:"
        echo "  create <repo-name>   Create a new GitHub repo and add it as a submodule"
        echo "  update               Update all submodules to latest remote main"
        echo "  status               Show sync status of every submodule"
        exit 1
        ;;
esac
