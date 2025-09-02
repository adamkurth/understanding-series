#!/bin/bash

# ==============================================================================
# Create a new GitHub repository and add it as a submodule.
#
# This script automates the following:
# 1. Checks for a clean working state in the parent repository.
# 2. Creates a new public repository on GitHub, initialized with a README.
# 3. Adds the new repository as a submodule to the parent.
# 4. Commits and pushes the changes.
#
# Usage: ./create_submodule.sh <new-repo-name>
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
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

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}
# -----------------------------------------

# Step 1: Validate Input and Prerequisites
if [ $# -ne 1 ]; then
    print_error "Usage: $0 <new-repo-name>"
fi
REPO_NAME=$1

if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI ('gh') is not installed. Please install it to continue."
fi

if [ ! -d "$PARENT_REPO_DIR" ]; then
    print_error "Parent repository directory not found at '$PARENT_REPO_DIR'."
fi

# Step 2: Check for a Clean State in the Parent Repository
print_info "Checking the status of the parent repository..."
cd "$PARENT_REPO_DIR"

if [ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then
    print_error "You are not on the 'main' branch. Please switch to main before running."
fi

if ! git diff-index --quiet HEAD --; then
    print_error "You have uncommitted changes. Please commit or stash them before running."
fi
print_success "Parent repository is clean."

# Step 3: Create and Initialize the GitHub Repository
print_info "Creating new GitHub repository '$REPO_NAME'..."
if ! gh repo create "$GITHUB_USERNAME/$REPO_NAME" --public --source=. --template=adamkurth/.github; then
    print_error "Failed to create GitHub repository. Please check your 'gh' authentication."
fi
print_success "Successfully created repository on GitHub."

# Step 4: Add the New Repository as a Submodule
print_info "Adding '$REPO_NAME' as a submodule..."
# Use HTTPS for better compatibility, but git@github.com works too.
git submodule add "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git" "$REPO_NAME"

# Step 5: Commit and Push the Changes
print_info "Committing and pushing the new submodule..."
git add .gitmodules "$REPO_NAME"
git commit -m "feat: Add $REPO_NAME submodule"
git push

print_success "All done! '$REPO_NAME' has been successfully added as a submodule."