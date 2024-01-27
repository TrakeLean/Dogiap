#!/bin/bash

# Check if .git folder exists
if [ ! -d ".git" ]; then
    echo "There is no .git folder in this directory. Exiting."
    exit 1
fi

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
name: Auto Update -> $RepoName

on:
  push:
    branches:
      - main

jobs:
  restart: $RepoName:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout to the branch
        uses: actions/checkout@v2

      - name: Stop $RepoName Script
        run: |
          # Find the process ID (PID) of the main.py script
          pid=$(ps aux | grep '[m]ain.py' | awk '{print $2}')

          if [ -n "$pid" ]; then
            # Terminate the current main.py process
            kill -9 $pid
            echo "> Terminated main.py process with PID $pid"
          else
            echo "> No running main.py process found"
          fi

      - name: Start $RepoName Script
        run: |
          # Restart the main.py script
          echo "> Restarting main.py"
          python3 main.py
EOL
fi

# Add the workflow file to Git
git add "$WorkflowFile"

# Commit the changes
git commit -m "Add GitHub Actions workflow file"

# Push the changes
git pull origin main
git push origin main
