#!/bin/bash

# Print status message to the terminal
function print_status() {
    local message="$1"
    local result="$2"

    if [ "$result" == "success" ]; then
        echo -e "\033[F\r> ${GREEN}$message${NC}                                   "
    else
        echo -e "\033[F\r> ${RED}$message${NC}                                   "
    fi
}

configure_git_and_ssh() {
# Check if SSH key exists
    echo "> Checking if SSH key exists"
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "> No SSH key found."
        while true; do
            # Prompt user to generate SSH key
            read -p "$(echo -e "${YELLOW}> Do you want to generate an SSH key? (y/n): ${NC}")" GenerateSsh

            if [ "$(echo "$GenerateSsh" | tr '[:upper:]' '[:lower:]')" = "y" ]; then
                # Prompt user to enter email address
                read -p "$(echo -e "${YELLOW}> Enter your email address: ${NC}")" EmailAddress

                # Generate SSH key
                echo "> Generating SSH key"
                ssh-keygen -t rsa -b 4096 -C "$EmailAddress"

                # Display the SSH public key
                echo "> Add the following SSH public key to your Git hosting service:"
                echo ""
                cat ~/.ssh/id_rsa.pub
                echo ""

                # Prompt user to add SSH key to GitHub
                echo "> Press Enter after adding the SSH key to continue."
                read -r
                break
            elif [ "$(echo "$GenerateSsh" | tr '[:upper:]' '[:lower:]')" = "n" ]; then
                echo "> Skipping SSH key generation. This is needed to connect to GitHub, exiting."
                exit 1
            else
                echo "> Invalid input. Please enter 'y' or 'n'."
            fi
        done
    else
        print_status "Checking if SSH key exists" "success"
    fi

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"  > /dev/null 2>&1

    # Check if the SSH key is already added
    if ! ssh-add -l | grep -q "$HOME/.ssh/id_rsa"; then
        # If not added, add the SSH private key to the ssh-agent
        ssh-add ~/.ssh/id_rsa > /dev/null 2>&1
    fi

    # Check if SSH key is associated with GitHub
    echo "> Testing SSH key connection to GitHub"
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        print_status "Testing SSH key connection to GitHub" "success"
    else
        print_status "Testing SSH key connection to GitHub" "failure"
        echo "> Please ensure that the SSH key is added to your GitHub account and try again."
        exit 1
    fi
    
    # Check if Git is available
    echo "> Checking if Git is installed"
    if ! command -v git &> /dev/null; then
        print_status "Checking if Git is installed" "failure"
        while true; do
            # Ask if the user wants to install Git
            read -p "$(echo -e "${YELLOW}> Git is not installed. Do you want to install Git? (y/n): ${NC}")" InstallGit

            if [ "$(echo "$InstallGit" | tr '[:upper:]' '[:lower:]')" = "y" ]; then
                # Inform the user about the installation process
                echo "> Installing Git"

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
                    echo -e "\r\033[K> Unsupported Linux distribution. Please install Git manually."
                    exit 1
                fi

                # Display success message
                print_status "Installing Git" "success"
                break
            elif [ "$(echo "$InstallGit" | tr '[:upper:]' '[:lower:]')" = "n" ]; then
                # User chose not to install Git
                echo "> Git is required for this script. Exiting."
                exit 1
            else
                echo "> Invalid input. Please enter 'y' or 'n'."
            fi
        done
    else
        print_status "Checking if Git is installed" "success"
    fi

    # Check if Docker is installed
    echo "> Checking if Docker is installed"
    if ! command -v docker &> /dev/null; then
        print_status "Checking if Docker is installed" "failure"
        while true; do
            # Ask if the user wants to install Docker
            read -p "$(echo -e "${YELLOW}> Docker is not installed. Do you want to install Docker? (y/n): ${NC}")" InstallDocker

            if [ "$(echo "$InstallDocker" | tr '[:upper:]' '[:lower:]')" = "y" ]; then
                # Inform the user about the installation process
                echo "> Installing Docker"

                # Check the Linux distribution and install Docker
                if [ -f /etc/redhat-release ]; then
                    # For Red Hat-based systems (e.g., CentOS)
                    sudo yum install -y docker
                elif [ -f /etc/debian_version ]; then
                    # For Debian-based systems (e.g., Ubuntu)
                    sudo apt-get update
                    sudo apt-get install -y docker.io
                else
                    # Unsupported Linux distribution
                    echo -e "> Unsupported Linux distribution. Please install Docker manually."
                    exit 1
                fi

                # Start Docker service
                sudo systemctl start docker

                # Display success message
                print_status "Installing Docker" "success"
                break
            elif [ "$(echo "$InstallDocker" | tr '[:upper:]' '[:lower:]')" = "n" ]; then
                # User chose not to install Docker
                echo "> Docker is required for this script. Exiting."
                exit 1
            else
                echo "> Invalid input. Please enter 'y' or 'n'."
            fi
        done
    else
        print_status "Checking if Docker is installed" "success"
    fi

    # Check if GitHub is already in known hosts
    echo "> Checking if GitHub is already in the known hosts"
    if grep -q "github.com" ~/.ssh/known_hosts; then
        print_status "Checking if GitHub is already in the known hosts" "success"
    else
        # Add GitHub to known hosts
        print_status "Checking if GitHub is already in the known hosts" "failure"
        echo "> Adding GitHub to known hosts"
        if ssh-keyscan github.com >> ~/.ssh/known_hosts; then
            print_status "Adding GitHub to known hosts" "success"
        else
            print_status "Adding GitHub to known hosts" "failure"
            exit 1
        fi
    fi
}

function server() {
    DirectoryPath="/srv/DogiapHookServer"
    DockerfilePath="$DirectoryPath/Hook-Server"

    DockerName="hook-server"

    # ANSI color codes
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
    
    configure_git_and_ssh

    # Check if directory exists
    echo "> Checking if directory exists"
    if [ -d "$DirectoryPath" ]; then
        print_status "Directory already exists" "success"
        while true; do
            read -p "$(echo -e "${YELLOW}> Directory already exists. Do you want to delete it? (y/n): ${NC}")" choice

            if [ "$(echo "$choice" | tr '[:upper:]' '[:lower:]')" = "y" ]; then
                sudo rm -r "$DirectoryPath"  # Delete existing directory
                sudo mkdir "$DirectoryPath"   # Create a new directory
                # Check if the directory was created successfully
                echo " "
                if [ $? -eq 0 ]; then
                    print_status "Directory '$DirectoryPath' created" "success"
                else
                    print_status "Failed to create the '$DirectoryPath' Exiting." "failed"
                    exit 1
                fi
                break
            elif [ "$(echo "$choice" | tr '[:upper:]' '[:lower:]')" = "n" ]; then
                exit 1
                break
            else
                echo -e "${YELLOW}> Invalid input"
            fi
        done
    else
        sudo mkdir "$DirectoryPath"
        print_status "Directory created" "success"
    fi

    sudo chown -R "$(whoami)" "$DirectoryPath"

    # Change into the directory
    cd $DirectoryPath || exit

    echo "> Initializing an empty Git repository"
    # Initialize an empty Git repository
    git init --quiet

    # Check if Git repository initialization was successful
    if [ $? -eq 0 ]; then
        print_status "Initializing an empty Git repository" "success"
    else
        print_status "Initializing an empty Git repository" "failed"
        exit 1
    fi

    # Attempt to add the remote origin without displaying output
    echo "> Adding remote 'origin'"
    git remote add -f origin https://github.com/TrakeLean/Dogiap > /dev/null 2>&1
    # Check if the remote was added successfully
    if [ $? -eq 0 ]; then
        print_status "Adding remote 'origin'" "success"
    else
        print_status "Adding remote 'origin'" "failed"
        exit 1
    fi

    git config core.sparseCheckout true
    echo "Hook-Server/*" >> .git/info/sparse-checkout

    # Pull changes from the remote repository
    echo "> Fetching the contents of 'Hook-Server' folder"
    if git pull --quiet origin main; then
        print_status "Fetching the contents of 'Hook-Server' folder" "success"
    else
        print_status "Fetching the contents of 'Hook-Server' folder" "failed"
        exit 1
    fi

    # Move into the 'Hook-Server' directory
    cd "$DockerfilePath" || exit

    # Check if the Docker container already exists
    if docker ps -a --format '{{.Names}}' | grep -q "^$DockerName"; then
        # Prompt user for action
        while true; do
            read -p "$(echo -e "${YELLOW}> Container \"$DockerName\" already exists. Do you want to rebuild? (y/n): ${NC}")" choice

            if [ "$(echo "$choice" | tr '[:upper:]' '[:lower:]')" = "y" ]; then
                echo "> Deleting existing Docker container \"$DockerName\""
                docker stop "$DockerName" > /dev/null 2>&1
                docker rm "$DockerName" > /dev/null 2>&1
                delete_status=$?
                if [ $delete_status -eq 0 ]; then
                    print_status "Deleting existing Docker container \"$DockerName\"" "success"

                    # Build and run the Docker image
                    echo "> Building Docker image \"$DockerName\""
                    # docker build -t $DockerName -f "$DockerfilePath" "$DirectoryPath/Hook-Server" > /dev/null 2>&1
                    build_status=$?
                    if [ $build_status -eq 0 ]; then
                        print_status "Building Docker image \"$DockerName\"" "success"
                        echo "> Running Docker image \"$DockerName\""
                        docker run -d -p 5000:5000 --name $DockerName $DockerName > /dev/null 2>&1

                        run_status=$?
                        if [ $run_status -eq 0 ]; then
                            print_status "Running Docker image \"$DockerName\"" "success"
                            break
                        else
                            print_status "Running Docker image \"$DockerName\"" "failure"
                            exit 1
                        fi
                    else
                        print_status "Building Docker image \"$DockerName\"" "failure"
                        exit 1
                    fi
                else
                    print_status "Deleting existing Docker container \"$DockerName\"" "failure"
                    exit 1
                fi
            elif [ "$(echo "$choice" | tr '[:upper:]' '[:lower:]')" = "n" ]; then
                echo "> Skipping deletion of existing Docker container \"$DockerName\""
                break
            else
                echo "> Invalid input. Please enter 'y' or 'n'."
            fi
        done
    else
        # Build and run the Docker image
        echo "> Building Docker image \"$DockerName\""
        # docker build -t $DockerName -f $DockerfilePath $DirectoryPath
 
        docker build -t $DockerName -f $DockerfilePath $DirectoryPath

        if [ $build_status -eq 0 ]; then 
            print_status "Building Docker image \"$DockerName\"" "success"
            echo "> Running Docker image \"$DockerName\""
            docker run -d -p 5000:5000 --name $DockerName $DockerName > /dev/null 2>&1
            run_status=$?
            if [ $run_status -eq 0 ]; then
                print_status "Running Docker image \"$DockerName\"" "success"
            else
                print_status "Running Docker image \"$DockerName\"" "failure"
                exit 1
            fi
        else
            print_status "Building Docker image \"$DockerName\"" "failure"
            exit 1
        fi
    fi
}

server
