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
WebHookServerUrl="http://129.242.219.112:5000/git-webhook"

# Create the directory if it doesn't exist
mkdir -p "$WorkflowDir"

if [ ! -f "$WorkflowFile" ]; then
    echo -n ">⌛ Creating GitHub Actions workflow file..."
    cat <<EOL > "$WorkflowFile"
name: Auto Update -> $RepoName

on:
  push:
    branches:
      - main

jobs:
  restart-$RepoName:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout to the branch
        uses: actions/checkout@v2

      - name: Send POST request to restart $RepoName
        run: |
          curl_response=\$(curl -X POST "\$WebHookServerUrl" -H "Content-Type: application/json" -H "X-GitHub-Event: push" --data "{\"reponame\": \"\$RepoName\"}" --fail --silent --show-error)
          
          if [ \$? -ne 0 ]; then
            echo ">❌ Failed to send webhook request"
            exit 1
          fi
          
          echo ">✅ Webhook request sent successfully. Response: \$curl_response"
EOL
echo -e "\r\033[K>✅ Creating GitHub Actions workflow file..."
else
    echo ">✅ GitHub Actions workflow file already exists. Skipping."
fi