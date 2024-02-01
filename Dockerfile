# Use an official Python runtime as a parent image
FROM python:3.9

# Install Git
RUN apt-get update &&     apt-get install -y git

# Set working directory
WORKDIR /app

# Copy everything from the host to the container
COPY . .

# Install dependencies (if needed)
RUN pip install --no-cache-dir -r requirements.txt

# Define the command to run on container start
CMD ["python3", "main.py"]
