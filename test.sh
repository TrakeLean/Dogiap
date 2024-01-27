#!/bin/bash

# Extract remote URL and repository name
RemoteUrl=$(git config --get remote.origin.url)
RepoName=$(basename -s .git $RemoteUrl)
WorkflowDir=".github/workflows"
WorkflowFile="$WorkflowDir/$RepoName.yml"

# Create the directory if it doesn't exist
mkdir -p "$WorkflowDir"

if [ ! -f "$WorkflowFile" ]; then
    echo "> Creating GitHub Actions workflow file..."
    cat <<EOL > "$WorkflowFile"
name: Trigger auto update for $RepoName

on:
  push:
    branches:
      - main

jobs:
  restart-script:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout to the branch
        uses: actions/checkout@v2

      - name: Stop Python script
        run: |
          # Add commands here to stop your Python script
          # For example, you might use pkill or a specific stop command

      - name: Start Python script
        run: |
          # Add commands here to start your Python script
          # For example, python your_script.py

EOL
fi

