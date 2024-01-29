# GitHub Automated Puller

The GitHub Automated Puller is a bash script (`AutoSetup.sh`) that streamlines the setting up of a GitHub repository for automated pulling within a Docker container. This utility is perfect for those who want to automate the deployment of their code updates without manual intervention.

## Features

- Validates the provided GitHub repository link.
- Generates an SSH key, if required, for authenticating with GitHub.
- Updates the remote repository URL to use SSH instead of HTTPS.
- Checks for Docker installation and offers installation if Docker is not found.
- Creates a Dockerfile if it doesn't exist and builds a Docker image from it.
- Runs the Docker image as a container.
- Adds and commits changes to the git repository and pushes them to GitHub.

## Prerequisites

Before running `AutoSetup.sh`, make sure you have the following prerequisites on your system:

- `git` - Distributed version control system
- `ssh` - Secure Shell for accessing remote servers
- `docker` - Platform for developing, shipping, and running applications within containers (will be installed by the script if not present)

## Usage

To use this script, ensure you have execution permissions. If needed, you can give the script execution permissions by running the command:

```sh
chmod +x AutoSetup.sh
```

Now you can run the script by providing your GitHub repository link as follows:

```sh
./AutoSetup.sh <GitHub repository link>
```

The script will guide you through a series of steps, including SSH key generation, updating the remote URL, checking Docker installation, building and running a Docker image, and updating the GitHub repository.

## Step-by-step Guide

Here's what `AutoSetup.sh` will do:

1. **Repository Link Validation:** At the start, the script will check if you've provided a valid GitHub repository link. It will accept both SSH and HTTPS formats.

2. **SSH Key Generation:** If no SSH key is present, it will prompt you to generate one, facilitate its creation, and instruct you to add it to your GitHub account.

3. **SSH Key Connection Testing:** It will test the SSH connection to GitHub to ensure that the key has been correctly added to your account.

4. **Remote URL Update:** The script will automatically update the repository remote URL to use SSH.

5. **Docker Installation Check and Setup:** If Docker isn't installed, the script will offer to install it. Once Docker is set up, it will check for the existence of a `Dockerfile` and create one if needed.

6. **Building and Running Docker Image:** With the Dockerfile in place, the script builds a new Docker image with your repository name, and runs it as a container.

7. **Git Workflow:** Finally, it will add all project files to git, commit them with a predefined message, and push the changes to the remote repository.

## Conclusion

The `AutoSetup.sh` script will help you automate the setup of a GitHub repository for your projects. By following the outlined steps, you can create a seamless workflow for deploying updates directly within a Docker container.

Remember to always review and test bash scripts before running them in your environment to ensure they perform as expected and comply with your project requirements.