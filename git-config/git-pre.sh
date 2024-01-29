#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    # Ask if the user wants to install Docker
    read -p "Docker is not installed. Do you want to install Docker? (y/n): " InstallDocker

    if [ "$InstallDocker" = "y" ]; then
        echo "> Installing Docker..."
        # Check the Linux distribution and install Docker accordingly
        if [ -f /etc/redhat-release ]; then
            # For Red Hat-based systems (e.g., CentOS)
            sudo yum install -y docker
        elif [ -f /etc/debian_version ]; then
            # For Debian-based systems (e.g., Ubuntu)
            sudo apt-get update
            sudo apt-get install -y docker.io
        else
            echo "> Unsupported Linux distribution. Please install Docker manually."
            exit 1
        fi

        # Start Docker service
        sudo systemctl start docker

        echo "> Docker has been installed successfully."
    else
        echo "> Docker is required for this script. Exiting."
        exit 1
    fi
fi

# Specify the path to the Dockerfile
dockerfile_path="Dockerfile"

# Check if Dockerfile exists
if [ ! -f "$dockerfile_path" ]; then
    echo "Dockerfile not found. Creating Dockerfile..."

    # Create a basic Dockerfile in the git-config folder
    cat <<EOL > "$dockerfile_path"
# Use an official Python runtime as a parent image
FROM python

# Set working directory
WORKDIR /app

# Copy files into the container
COPY ../main.py .

# Define the command to run on container start
CMD ["python", "main.py"]
EOL

    echo "Dockerfile created successfully."
fi










# # Get the parent folder name from the Git repository
# parent_folder_name=$(basename "$(dirname "$(git rev-parse --git-dir)")")

# # Convert parent folder name to lowercase
# parent_folder_name=$(echo "$parent_folder_name" | tr '[:upper:]' '[:lower:]')

# echo "Parent folder name: $parent_folder_name"



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
