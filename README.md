# Dogiap - Continual GitHub Repo Synchronization

![GitHub contributors](https://img.shields.io/github/contributors/TrakeLean/Dogiap)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/TrakeLean/Dogiap)
[![wakatime](https://wakatime.com/badge/user/25484680-9f95-4670-92ea-9abd3854b948/project/018d5bd0-3d8f-4db9-af17-62073ca412b0.svg)](https://wakatime.com/badge/user/25484680-9f95-4670-92ea-9abd3854b948/project/018d5bd0-3d8f-4db9-af17-62073ca412b0)
![GitHub stars](https://img.shields.io/github/stars/TrakeLean/Dogiap?style=social)
![GitHub forks](https://img.shields.io/github/forks/TrakeLean/Dogiap?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/TrakeLean/Dogiap?style=social)

## Introduction

Dogiap is a tool designed to streamline the process of maintaining your codebase when hosting scripts or services on a server. By automating the synchronization with your GitHub repository, Dogiap ensures that the server-side code is continuously updated without manual intervention. It integrates a GitHub Actions workflow and a server-side service for relentless uptime and synchronicity.

## Key Features

- **Automated GitHub Pulls**: Dogiap sets up a GitHub Action which is triggered on updates to your repository, initiating a pull request on your server.

- **Server Synchronization**: A server-side handler is established to receive these requests and perform git pull operations, ensuring that the server's code is matching the latest state of the repository.

- **Service Management**: Alongside the synchronization mechanism, Dogiap creates a system service ensuring that your script or server application is perpetually running.

- **GitHub Actions Integration**: A configuration file for GitHub Actions is automatically installed into your repository, coupling your code updates to server-side deployment actions.

- **Robust Uptime**: With the combination of these features, your server-hosted application will maintain an unwavering presence, free from manual update needs and downtime concerns.

In essence, Dogiap encapsulates the entire workflow for a developer looking to preserve a consistent, up-to-date server environment that aligns with their GitHub repository progress, whilst guaranteeing their applications are always operational.

## Installation and Setup Instructions

To install and set up the Dogiap package, perform the following steps:

1. Clone the repository from GitHub:
    ```bash
    git clone https://github.com/yourusername/yourproject.git
    ```

2. Navigate to the project directory:
    ```bash
    cd yourproject
    ```

3. Begin by building the Debian package with:
    ```bash
    dpkg-deb --build Dogiap
    ```

4. If you wish to inspect the contents of the generated Debian package, you can do so with:
    ```bash
    dpkg-deb -c Dogiap.deb
    ```

5. Proceed to install the package using `apt-get`. The `-f` flag is used to ensure that any missing dependencies are also installed:
    ```bash
    sudo apt-get install -f ./Dogiap.deb
    ```

These steps will ensure that the Dogiap package is built and installed correctly on your system.

6. Once the package is installed, use the setup script to configure Dogiap. Make sure to replace `your-repository` with the name of your local cloned repository and use the appropriate URL for your GitHub repository:
    
    ```bash
    cd your-repository/
    dogiap --setup git@github.com:TrakeLean/Dogiap.git
    ```

Make sure you modify the commands with the correct repository URLs and paths as required for your specific project and setup.

### Setting Up the Web Server

The server must be configured to handle incoming webhook requests:

1. Run the setup script with the `--setup` flag.

2. The server will start automatically, listening for webhook requests on the configured port (default: 5000).

## Usage

- To start the server: `dogiap --start`
- To check if the server is running: `dogiap --check`
- To list all services: `dogiap --list`
- To view the service logs: `dogiap --log`
- To delete a service: `dogiap --delete servicename`

## Version

The current version of the project script is 1.0.6.

## Contributions

Contributions are welcome. Please fork this repository, make your changes, and submit a pull request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Here while developing

- sudo rm -r /srv/DogiapDebFile/Dogiap.deb && sudo apt-get remove -y dogiap && dpkg-deb --build Dogiap && sudo mv Dogiap.deb /srv/DogiapDebFile && sudo apt-get install -f /srv/DogiapDebFile/Dogiap.deb

sudo rm -f /srv/DogiapDebFile/Dogiap.deb && \
sudo apt-get remove -y dogiap && \
dpkg-deb --build Dogiap && \
sudo mv Dogiap.deb /srv/DogiapDebFile/ && \
cd /srv/DogiapDebFile/ && \
dpkg-deb -c Dogiap.deb && \
sudo apt-get install -f ./Dogiap.deb && \
cd /home/tarek

# Why is this fkr spawning in root
- sudo rm -r Hook-Server/ && sudo rm -r LICENSE.md && sudo rm -r README.md && sudo rm -r usr/bin/dogiap && sudo rm -r .git
- sudo rm -r Hook-Server/ && sudo rm -r LICENSE.md && sudo rm -r README.md && sudo rm -r usr/bin/dogiap && sudo rm -r .git