#!/bin/bash

# Check if .git folder exists
echo -n ">⌛ Checking if .git folder exists..."
if [ ! -d ".git" ]; then
    echo ">❌ There is no .git folder in this directory. Exiting."
    exit 1
fi
echo -e "\r\033[K>✅ Checking if .git folder exists..."

# Extract remote URL and repository name
RemoteUrl=$(git config --get remote.origin.url)
RepoName=$(basename -s .git $RemoteUrl)

# Setup variables for GitHub Actions
WorkflowDir="./Automation"

# Setup variables for configuration file
ConfigurationFilePath="$WorkflowDir/settings.json"
ScriptPath="./main.py"

# Setup variables for Docker file
DockerFilePath="$WorkflowDir/Dockerfile"

# Create the directory if it doesn't exist
echo -n ">⌛ Setting up directory..."
mkdir -p "$WorkflowDir"
echo -e "\r\033[K>✅ Setting up directory..."

if [ ! -f $DockerFilePath ]; then
    echo -n ">⌛ Creating Dockerfile..."  
    cat <<EOL > "$DockerFilePath"
# Use an official Python runtime as a parent image
FROM python

# Set working directory
WORKDIR /app

# Copy files into the container
COPY ../main.py .

# Define the command to run on container start
CMD ["python", "main.py"]
EOL
fi
echo -e "\r\033[K>✅ Creating Dockerfile..."

# Build and run the Docker image
echo -n ">⌛ Building Docker image \"$RepoName\"..."
docker build -t $RepoName .
echo -e "\r\033[K>✅ Building Docker image \"$RepoName\"..."
docker run -it -d --name $RepoName $RepoName
echo -n ">✅ Running Docker image \"$RepoName\"..."

# Add the workflow file to Git
echo -n ">⌛ Adding all files to Git..."
git add .
echo  -e "\r\033[K>✅ Adding all files to Git..."

# Commit the changes
echo -n ">⌛ Committing the changes..."
git commit -m "Everthing setup for automatic GitHub pulls"
echo -e "\r\033[K>✅ Committing the changes..."

# Push the changes
echo -n ">⌛ Pushing the changes..."
git push origin main
echo -e "\r\033[K>✅ Pushing the changes..."
fi