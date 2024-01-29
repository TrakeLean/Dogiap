#!/bin/bash

# Check if .git folder exists
echo -n ">⌛ Checking if .git folder exists..."
if [ ! -d ".git" ]; then
    echo ">❌ There is no .git folder in this directory. Exiting."
    exit 1
fi
echo -e "\r\033[K>✅ Checking if .git folder exists...  Successful"

# Extract remote URL and repository name
RemoteUrl=$(git config --get remote.origin.url)
RepoName=$(basename -s .git $RemoteUrl | tr '[:upper:]' '[:lower:]')

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    # Ask if the user wants to install Docker
    read -p ">🐳 Docker is not installed. Do you want to install Docker? (y/n): " InstallDocker

    if [ "$InstallDocker" = "y" ]; then
        # Inform the user about the installation process
        echo -n ">⌛ Installing Docker..."

        # Check the Linux distribution and install Docker accordingly
        if [ -f /etc/redhat-release ]; then
            # For Red Hat-based systems (e.g., CentOS)
            sudo yum install -y docker
        elif [ -f /etc/debian_version ]; then
            # For Debian-based systems (e.g., Ubuntu)
            sudo apt-get update
            sudo apt-get install -y docker.io
        else
            # Unsupported Linux distribution
            echo -e "\r\033[K>❌ Unsupported Linux distribution. Please install Docker manually."
            exit 1
        fi

        # Start Docker service
        sudo systemctl start docker

        # Display success message
        echo -e "\r\033[K>✅ Docker has been installed successfully."
    else
        # User chose not to install Docker
        echo ">🐳 Docker is required for this script. Exiting."
        exit 1
    fi
fi

# Setup variables for Docker file
DockerFilePath="./Dockerfile"

# Check if Dockerfile already exists if not create it
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
  echo -e "\r\033[K>✅ Creating Dockerfile...   Successful"
else
  echo -e "\r\033[K>✅ Dockerfile already exists... Skipping"
fi

# Build and run the Docker image
echo -n -e ">⌛ Building Docker image \"$RepoName\"...\n"
sudo docker build -t $RepoName .
build_status=$?
if [ $build_status -eq 0 ]; then
    echo -e "\r\033[K>✅ Building Docker image \"$RepoName\"... Successful"
    echo -n -e "\n>⌛ Running Docker image \"$RepoName\"..."
    sudo docker run -it -d --name $RepoName $RepoName
    run_status=$?
    if [ $run_status -eq 0 ]; then
        echo -n "\r\033[K>✅ Running Docker image \"$RepoName\"... Successful"
    else
        echo -e "\r\033[K>❌ Running Docker image \"$RepoName\"... Failed"
        exit 1
    fi
else
    echo -e "\r\033[K>❌ Building Docker image \"$RepoName\"... Failed"
    exit 1
fi

# Add the workflow file to Git
echo -n ">⌛ Adding all files to Git..."
git add .
add_status=$?
echo -e "\r\033[K>✅ Adding all files to Git... Successful"

# Commit the changes
echo -n ">⌛ Committing the changes..."
git commit -m "Everything set up for automatic GitHub pulls"
commit_status=$?
if [ $commit_status -eq 0 ]; then
    echo -e "\r\033[K>✅ Committing the changes... Successful"
else
    echo -e "\r\033[K>❌ Committing the changes... Failed"
    exit 1
fi

# Push the changes
echo -n ">⌛ Pushing the changes..."
git push origin main
push_status=$?
if [ $push_status -eq 0 ]; then
    echo -e "\r\033[K>✅ Pushing the changes... Successful"
else
    echo -e "\r\033[K>❌ Pushing the changes... Failed"
    exit 1
fi
