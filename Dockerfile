# Use an official Python runtime as a parent image
FROM python:3.9

# Install Git
RUN apt-get update &&     apt-get install -y git

# Set working directory
WORKDIR /app

# Mount data directory as a volume
VOLUME /app/data

# Install dependencies (if needed)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Define the command to run on container start
CMD ["python3", "main.py"]
