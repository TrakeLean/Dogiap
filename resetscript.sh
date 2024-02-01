# # Remove the .deb file
# sudo dpkg -i ~/Dogiap.deb

# # apt remove dogiap
# sudo apt-get remove -y dogiap

# # Build the Debian package
# dpkg-deb --build Dogiap

# # Install the Debian package
# sudo dpkg -i ~/Dogiap.deb

CurrentRemoteUrl=$(git remote get-url origin) > /dev/null 2>&1
echo "Current remote url: $CurrentRemoteUrl"
