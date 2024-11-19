#!/bin/bash

# Script to create a new GitHub repository and add it as a submodule to the 'understanding-series' repository.
# Usage: ./create_submodule.sh <repo-name>

# Exit immediately if a command exits with a non-zero status.
set -e

# --------------------------- Configuration ---------------------------

# Check if the repository name is provided as an argument.
if [ $# -ne 1 ]; then
    echo "Usage: $0 <repo-name>"
    exit 1
fi

# Repository name passed as an argument.
REPO_NAME=$1

# Replace with your GitHub username.
GITHUB_USERNAME="adamkurth"

# Replace with the absolute path to your 'understanding-series' repository.
PARENT_DIR="$HOME/Documents/vscode/code/understanding-series"

# Temporary directory for initializing the new repository.
TEMP_DIR="/tmp/$REPO_NAME"

# ------------------------- Pre-requisites Check -------------------------

# Check if GitHub CLI 'gh' is installed.
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI 'gh' is not installed. Please install it before running this script."
    exit 1
fi

# Check if Git is installed.
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install it before running this script."
    exit 1
fi

# Check if the parent directory exists.
if [ ! -d "$PARENT_DIR" ]; then
    echo "Error: Parent directory '$PARENT_DIR' does not exist. Please check the path."
    exit 1
fi

# ------------------------- Script Execution -------------------------

echo "Starting the process to create and add submodule '$REPO_NAME'..."

# Step 1: Create a new GitHub repository using GitHub CLI.
echo "Creating new GitHub repository '$REPO_NAME'..."
gh repo create "$GITHUB_USERNAME/$REPO_NAME" --public --confirm

# Step 2: Clone the new repository to a temporary directory.
echo "Cloning the new repository to a temporary directory..."
git clone "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git" "$TEMP_DIR"

# Step 3: Initialize the repository with a README.md file.
echo "Initializing the repository with a README.md file..."
cd "$TEMP_DIR"
echo "# $REPO_NAME" > README.md

# Step 4: Commit and push the initial commit to GitHub.
echo "Committing and pushing the initial commit..."
git add README.md
git commit -m "Initial commit"
git push -u origin main

# Step 5: Navigate to the parent repository directory.
echo "Navigating to the parent repository directory..."
cd "$PARENT_DIR"

# Step 6: Add the new repository as a submodule in the parent repository.
echo "Adding the new repository as a submodule..."
git submodule add "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git" "$REPO_NAME"

# Step 7: Commit and push the changes in the parent repository.
echo "Committing and pushing changes in the parent repository..."
git add .gitmodules "$REPO_NAME"
git commit -m "Add '$REPO_NAME' submodule"
git push

# Step 8: Clean up the temporary directory.
echo "Cleaning up the temporary directory..."
rm -rf "$TEMP_DIR"

echo "Successfully added '$REPO_NAME' as a submodule to the 'understanding-series' repository."