#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo ">❌ Usage: $0 <GitHub repository link>"
    exit 1
fi

# Define patterns for GitHub repository links
ssh_pattern="git@github.com:*/*"
https_pattern="https://github.com/*/*"

# Check if the argument matches either SSH or HTTPS GitHub repository patterns
if [[ "$1" =~ $ssh_pattern || "$1" =~ $https_pattern ]]; then
    echo ">✅ Argument is a GitHub repository link: $1"
else
    echo ">❌ Invalid GitHub repository link. Please provide a valid link."
    exit 1
fi

# Check if SSH is available
if ! command -v ssh &> /dev/null; then
    # Ask if the user wants to install SSH
    read -p ">🔑 SSH is not installed. Do you want to install SSH? (y/n): " InstallSSH

    if [ "$InstallSSH" = "y" ]; then
        # Inform the user about the installation process
        echo -n ">⌛ Installing SSH..."

        # Check the Linux distribution and install SSH accordingly
        if [ -f /etc/redhat-release ]; then
            # For Red Hat-based systems (e.g., CentOS)
            sudo yum install -y openssh
        elif [ -f /etc/debian_version ]; then
            # For Debian-based systems (e.g., Ubuntu)
            sudo apt-get update
            sudo apt-get install -y openssh-client
        else
            # Unsupported Linux distribution
            echo -e "\r\033[K>❌ Unsupported Linux distribution. Please install SSH manually."
            exit 1
        fi

        # Display success message
        echo -e "\r\033[K>✅ SSH has been installed successfully."
    else
        # User chose not to install SSH
        echo ">🔑 SSH is required for this script. Exiting."
        exit 1
    fi
fi

# Check if SSH key exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo ">❌ No SSH key found."

    # Prompt user to generate SSH key
    read -p ">❓ Do you want to generate an SSH key? (y/n): " GenerateSsh

    if [ "$GenerateSsh" = "y" ]; then
        # Prompt user to enter email address
        read -p ">🖊️ Enter your email address: " EmailAddress

        # Generate SSH key
        echo ">🔑 Generating SSH key..."
        ssh-keygen -t rsa -b 4096 -C "$EmailAddress"

        # Start the ssh-agent in the background
        eval "$(ssh-agent -s)"

        # Add SSH private key to the ssh-agent
        ssh-add ~/.ssh/id_rsa

        # Display the SSH public key
        echo ">🔗 Add the following SSH public key to your Git hosting service:"
        echo ""
        cat ~/.ssh/id_rsa.pub
        echo ""

        # Prompt user to add SSH key to GitHub
        echo ">⌨️ Press Enter after adding the SSH key to continue."
        read -r
    else
        echo ">⏩ Skipping SSH key generation. This is needed to connect to GitHub, exiting."
        exit 1
    fi
fi

# Check if SSH key is associated with GitHub
echo "> 🌐 Testing SSH key connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "> ✅ SSH key is connected to GitHub."
else
    echo "> ❌ Unable to authenticate with GitHub using the SSH key."
    echo "> 🛑 Please ensure that the SSH key is added to your GitHub account and try again."
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null; then
    # Ask if the user wants to install Git
    read -p ">🚀 Git is not installed. Do you want to install Git? (y/n): " InstallGit

    if [ "$InstallGit" = "y" ]; then
        # Inform the user about the installation process
        echo -n ">⌛ Installing Git..."

        # Check the Linux distribution and install Git accordingly
        if [ -f /etc/redhat-release ]; then
            # For Red Hat-based systems (e.g., CentOS)
            sudo yum install -y git
        elif [ -f /etc/debian_version ]; then
            # For Debian-based systems (e.g., Ubuntu)
            sudo apt-get update
            sudo apt-get install -y git
        else
            # Unsupported Linux distribution
            echo -e "\r\033[K>❌ Unsupported Linux distribution. Please install Git manually."
            exit 1
        fi

        # Display success message
        echo -e "\r\033[K>✅ Git has been installed successfully."
    else
        # User chose not to install Git
        echo ">🚀 Git is required for this script. Exiting."
        exit 1
    fi
fi

# Update remote URL to use SSH
if [[ $1 == "https://"* ]]; then
    echo "> 🔄 Updating remote URL to use SSH..."

    # Extracting username and repository name using regular expressions
    regex="https://github.com/([^/]+)/([^/]+)\.git"
    if [[ $1 =~ $regex ]]; then
        GithubUsername="${BASH_REMATCH[1]}"
        RepoName="${BASH_REMATCH[2]}"
        RepoName=$(echo "$RepoName" | tr '[:upper:]' '[:lower:]')  # Convert RepoName to lowercase

        git remote set-url origin "git@github.com:$GithubUsername/$RepoName.git"
    fi
fi

# If the URL is already in SSH format, print the extracted values
if [[ $1 == "git@github.com:"* ]]; then
    regex="git@github.com:([^/]+)/([^/]+)\.git"
    if [[ $1 =~ $regex ]]; then
        GithubUsername="${BASH_REMATCH[1]}"
        RepoName="${BASH_REMATCH[2]}"
        RepoName=$(echo "$RepoName" | tr '[:upper:]' '[:lower:]')  # Convert RepoName to lowercase
    fi
fi

# Setup variables for GitHub Actions workflow file
WorkflowFilePath="./.github/workflows/automatic-pull.yml"
WebHookServerUrl="129.242.219.112:5000/git-webhook"

# Check if GitHub Actions workflow file already exists; if not, create it
if [ ! -f "$WorkflowFilePath" ]; then
    echo -n ">⌛ Creating GitHub Actions directory and file..."  
    mkdir -p ./.github/workflows
    cat <<EOL > "$WorkflowFilePath"
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
          curl_response=\$(curl -X POST "$WebHookServerUrl" -H "Content-Type: application/json" -H "X-GitHub-Event: push" --data "{\"$RepoName\": \"$RepoName\"}" --fail --silent --show-error)
          
          if [ \$? -ne 0 ]; then
            echo ">❌ Failed to send webhook request"
            exit 1
          fi
          
          echo ">✅ Webhook request sent successfully. Response: \$curl_response"
          exit 0
EOL
    echo -e "\r\033[K>✅ Creating GitHub Actions directory and file...   Successful"
else
    echo -e "\r\033[K>✅ GitHub Actions directory and file already exists... Skipping"
fi


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

# Check if the Docker container already exists
if sudo docker ps -a | grep -q $RepoName; then
    echo "Container \"$RepoName\" already exists."

    # Prompt user for action
    read -p "Do you want to delete and build a new one (y/n)? " choice
    if [ "$choice" == "y" ]; then
        echo -n -e ">⌛ Deleting existing Docker container \"$RepoName\"...\n"
        sudo docker stop $RepoName && sudo docker rm $RepoName
        delete_status=$?
        if [ $delete_status -eq 0 ]; then
            echo -e "\r\033[K>✅ Deleted existing Docker container \"$RepoName\""

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
                    echo -e "\r\033[K>✅ Running Docker image \"$RepoName\"... Successful"
                else
                    echo -e "\r\033[K>❌ Running Docker image \"$RepoName\"... Failed"
                    exit 1
                fi
            else
                echo -e "\r\033[K>❌ Building Docker image \"$RepoName\"... Failed"
                exit 1
            fi
        else
            echo -e "\r\033[K>❌ Failed to delete existing Docker container \"$RepoName\""
            exit 1
        fi
    else
        # Restart the existing Docker container
        echo -n -e ">⌛ Restarting existing Docker container \"$RepoName\"...\n"
        sudo docker restart $RepoName
        restart_status=$?
        if [ $restart_status -eq 0 ]; then
            echo -e "\r\033[K>✅ Restarting existing Docker container \"$RepoName\"... Successful"
        else
            echo -e "\r\033[K>❌ Restarting existing Docker container \"$RepoName\"... Failed"
            exit 1
        fi
    fi
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
exit 0