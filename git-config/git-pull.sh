#!/bin/bash

Dir=../.

cd "$Dir"
pwd

# Check if SSH key exists
if [ ! -f ~/.ssh/id_rsa ]; then
	echo "> No SSH key found."

	# Prompt user to generate SSH key
	read -p "> Do you want to generate an SSH key? (y/n): " GenerateSsh

	if [ "$GenerateSsh" = "y" ]; then
		echo "> Is this your email address?: $(git config user.email)"
		read -p "> (y/n): " IsEmailCorrect

		if [ "$IsEmailCorrect" = "y" ]; then
			EmailAddress=$(git config user.email)
		else
			read -p "> Enter your email address: " EmailAddress
		fi
		echo "> Generating SSH key..."
		ssh-keygen -t rsa -b 4096 -C $EmailAddress
		eval "$(ssh-agent -s)"
		ssh-add ~/.ssh/id_rsa

		echo "> Add the following SSH public key to your Git hosting service:"
		echo ""
		cat ~/.ssh/id_rsa.pub
		echo ""
		echo "> Press Enter after adding the SSH key to continue."
		read -r
	else
		echo "> Skipping SSH key generation. Exiting."
		exit 1
	fi
fi

# Check if SSH key is associated with GitHub
echo "> Testing SSH key connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
	echo "> SSH key is connected to GitHub."
else
	echo "> Unable to authenticate with GitHub using the SSH key."
	echo "> Please ensure that the SSH key is added to your GitHub account and try again."
	exit 1
fi

# Extract the username using grep and cut
GithubUsername=$(echo $RemoteUrl | grep -oP '(?<=github\.com\/)[^\/]+')

if [[ $remote_url == "https://"* || $remote_url == "http://"* ]]; then
    echo "> Updating remote URL to use SSH..."
    git remote set-url origin "git@github.com:$GithubUsername/$RepoName.git"
fi

# Perform Git push
echo "> Pulling..."
git push


echo "> Everything's done."