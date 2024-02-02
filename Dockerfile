# Use an official Python runtime as a parent image
FROM python:3.9

# Install Git, SSH and other dependencies
RUN apt-get update &&     apt-get install -y git &&     rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy everything from the host to the container
COPY . .

# Install dependencies (if needed)
RUN pip install --no-cache-dir -r requirements.txt

# Define the command to run on container start
CMD ["python3", "main.py"]
