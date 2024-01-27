#!/bin/bash

# Navigate to your Docker container directory
cd /path/to/your/docker/container

# Fetch the latest changes from the GitHub repository
git fetch origin

# Get the current commit hash
current_commit=$(git rev-parse HEAD)

# Get the latest commit hash from the remote repository
latest_commit=$(git rev-parse origin/master)

# Check if there are new changes
if [ "$current_commit" != "$latest_commit" ]; then
    # Pull the latest changes
    # git pull origin master
    echo "pull"

    # Restart your Docker container
    # docker-compose restart
    echo "restart"
fi
