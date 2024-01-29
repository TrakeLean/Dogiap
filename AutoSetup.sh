#!/bin/bash

# Check if .git folder exists
echo -n ">⌛ Checking if .git folder exists..."
if [ ! -d ".git" ]; then
    echo ">❌ Are you in the Root directory of your repo? There is no .git folder in this directory. Exiting."
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
        echo -e "\r\033[K>✅ Running Docker image \"$RepoName\"... Successful"
    else
        echo -e "\r\033[K>❌ Running Docker image \"$RepoName\"... Failed"
        exit 1
    fi
else
    echo -e "\r\033[K>❌ Building Docker image \"$RepoName\"... Failed"
    exit 1
fi




-e "\r\033[K>✅
-e "\r\033[K>❌


# Check if SSH key exists
if [ ! -f ~/.ssh/id_rsa ]; then
	echo ">❌ No SSH key found."

	# Prompt user to generate SSH key
	read -p ">❓ Do you want to generate an SSH key? (y/n): " GenerateSsh

	if [ "$GenerateSsh" = "y" ]; then
		read -p ">❓ Is this your email address?: $(git config user.email) (y/n): " IsEmailCorrect

		if [ "$IsEmailCorrect" = "y" ]; then
			EmailAddress=$(git config user.email)
		else
			read -p ">🖊️ Enter your email address: " EmailAddress
		fi
		echo ">🔑 Generating SSH key..."
		ssh-keygen -t rsa -b 4096 -C $EmailAddress
		eval "$(ssh-agent -s)"
		ssh-add ~/.ssh/id_rsa

		echo ">🔗 Add the following SSH public key to your Git hosting service:"
		echo ""
		cat ~/.ssh/id_rsa.pub
		echo ""
		echo ">⌨️ Press Enter after adding the SSH key to continue."
		read -r
	else
		echo ">⏩ Skipping SSH key generation. Exiting."
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

# Extract the username using grep and cut
GithubUsername=$(echo $RemoteUrl | grep -oP '(?<=github\.com\/)[^\/]+')

if [[ $remote_url == "https://"* || $remote_url == "http://"* ]]; then
    echo "> 🔄 Updating remote URL to use SSH..."
    git remote set-url origin "git@github.com:$GithubUsername/$RepoName.git"
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
