#!/bin/bash

# Get the parent folder name from the Git repository
# parent_folder_name=$(basename "$(dirname "$(git rev-parse --git-dir)")")
# echo "Parent folder name: $parent_folder_name"

# # Define the container name and image
# container_name="${parent_folder_name}_container"
# image="my_image:tag"

# # Check if the container already exists
# if docker ps -a --format '{{.Names}}' | grep -q "^$container_name$"; then
#     echo "Container '$container_name' already exists. Resetting..."
    
#     # Stop and remove existing container
#     docker stop "$container_name" && docker rm "$container_name"
# fi

# # Create a new container
# docker run -d --name "$container_name" "$image"
