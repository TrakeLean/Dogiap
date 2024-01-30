# GitHub Automated Puller

The GitHub Automated Puller is a bash script (`AutoSetup.sh`) that streamlines the setting up of a GitHub repository for automated pulling within a Docker container. This utility is perfect for those who want to automate the deployment of their code updates without manual intervention.

## Features



sudo rm -r Dogiap.deb 
sudo apt-get remove -y dogiap
dpkg-deb --build Dogiap
sudo apt-get install -f ~/Dogiap.deb
which dogiap

# Remove the .deb file
sudo rm -r Dogiap.deb 

# apt remove dogiap
sudo apt-get remove -y dogiap

# Build the Debian package
dpkg-deb --build Dogiap

# Install the Debian package
sudo dpkg -i ~/Dogiap.deb

# If needed, fix dependencies
sudo apt-get install -f

# Test
dogiap git@github.com:TrakeLean/Dogiap.git

- Validates the provided GitHub repository link.
- Generates an SSH key, if required, for authenticating with GitHub.
- Updates the remote repository URL to use SSH instead of HTTPS.
- Checks for the installation of essential tools such as Docker, Git, and SSH, and offers installation if any of them is not found.
- Creates a Dockerfile if it doesn't exist and builds a Docker image from it.
- Runs the Docker image as a container.
- Adds and commits changes to the git repository and pushes them to GitHub.

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

5. **Environment Setup:** The script checks for the presence of essential tools such as Git, Docker, and SSH. If any of these tools are not installed, the script will prompt the user to install them. Once Docker, Git, and SSH are set up, the script further checks for the existence of a `Dockerfile` and creates one if needed.


6. **Building and Running Docker Image:** With the Dockerfile in place, the script builds a new Docker image with your repository name, and runs it as a container.

7. **Git Workflow:** Finally, it will add all project files to git, commit them with a predefined message, and push the changes to the remote repository.

## Conclusion

The `AutoSetup.sh` script will help you automate the setup of a GitHub repository for your projects. By following the outlined steps, you can create a seamless workflow for deploying updates directly within a Docker container.

Remember to always review and test bash scripts before running them in your environment to ensure they perform as expected and comply with your project requirements.