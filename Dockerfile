# Use an official Python runtime as a parent image
FROM python

# Install Git
RUN apt-get update && \
    apt-get install -y git

# Set working directory
WORKDIR /app

# Clone or pull the Git repository
RUN git clone https://github.com/TrakeLean/GitHub-Automated-Puller.git .

# Install dependencies (if needed)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Define the command to run on container start
CMD ["python3", "main.py"]
