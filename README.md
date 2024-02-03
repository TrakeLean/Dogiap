## Dogiap - Automatic GitHub Repository Puller

![GitHub contributors](https://img.shields.io/github/contributors/TrakeLean/Dogiap)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/TrakeLean/Dogiap)
![GitHub stars](https://img.shields.io/github/stars/TrakeLean/Dogiap?style=social)
![GitHub forks](https://img.shields.io/github/forks/TrakeLean/Dogiap?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/TrakeLean/Dogiap?style=social)

Dogiap is an automated script that simplifies the process of setting up continuous deployment for your GitHub repositories. With Dogiap, you can set up your server so that once you push changes to your GitHub repository, it will automatically pull updates and redeploy your project.

### Features

- Clone and set up a project from a GitHub repository
- Automatically pull updates from GitHub when changes are pushed
- Easy to install and use on your server

### Prerequisites

- Linux server with internet access

### Installation

Before using the script, Dogiap must be installed on your system. It can be installed using the `apt` package manager:

```bash
sudo apt install dogiap
```

### Usage

To get started with Dogiap, you'll first need to set up your server to handle webhook requests. This is achieved by using the `--setup` flag.

Run the following command to set up Dogiap on your server:

```bash
dogiap --setup
```

Once the setup is complete, you can start deploying your GitHub repository by simply passing the repository URL to Dogiap:

```bash
dogiap <GitHub repository link>
```

### Commands

- `dogiap <GitHub repository link>`: Initialize and set up the repository for automatic pulling.
- `dogiap --setup`: Set up the server for webhook requests. (will also start the server)
- `dogiap --start`: Start the webhook server. (if it ever shuts down)
- `dogiap --version` or `dogiap --v`: Display version information.

### Examples

Setting up the server:

```bash
dogiap --setup
```

Cloning and setting up a repository:

```bash
dogiap git@github.com:TrakeLean/Dogiap.git
```

Starting the webhook server:

```bash
dogiap --start
```

### How It Works

Upon initialization, Dogiap checks if the current directory is empty and sets up necessary permissions. After confirming the installation of Git, SSH, Docker, and determining the installation paths, it proceeds to configure SSH keys, ensuring a secure connection to GitHub.

Dogiap clones the specified repository and creates a Dockerfile and GitHub Actions workflow designed to handle automatic pulling of updates. The workflow includes a webhook that triggers a POST request to a server, notifying it about the pushed changes and effectively restarting the associated Docker container to reflect updates.

### Contributions

Contributions to this project are welcome. Please visit the repository at https://github.com/TrakeLean/Dogiap.git to report issues or submit pull requests.

### License

This project is open-sourced under the [GNU General Public License v3.0](LICENSE.md).

#### Commands used for building (currently)
- sudo rm -r Dogiap.deb
- sudo apt-get remove -y dogiap
- dpkg-deb --build Dogiap
- sudo apt-get install -f ~/Dogiap.deb

---

Enjoy using Dogiap for effortless and automated deployments on your server!
