# Use an official Python runtime as a parent image
FROM python

# Set working directory
WORKDIR /app

# Copy requirements.txt separately to leverage Docker caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Define the command to run on container start
CMD ["python", "main.py"]