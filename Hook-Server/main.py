from flask import Flask, request
import json
import os
import time
import subprocess

app = Flask(__name__)

# :)
@app.route('/git-webhook', methods=['POST'])
def webhook():
    try:
        payload = request.get_data(as_text=True)
        data = json.loads(payload)

        # Check if the request is from GitHub
        github_event = request.headers.get('X-GitHub-Event')

        if github_event == 'push':
            # Ensure ContainerName comes from a trusted source
            ContainerName = data.get("ContainerName")
            if ContainerName is None:
                raise ValueError("ContainerName is missing in the payload")
            
            print("Webhook received from GitHub - Push event:", ContainerName)

            cmd = f'docker inspect --format "{{.Config.Labels.program_path}}" {ContainerName}'
            ResultPath = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            # Do git pull from the ResultPath directory to update the program files
            cmd = f'cd {ResultPath.stdout.strip()} && git pull'
            ResultPull = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            print(ResultPull.stdout.strip())
            
            return "Success"
        else:
            print(f"Ignoring webhook - Unexpected GitHub event: {github_event}")
            return "Ignored"
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return "Internal Server Error", 500

# Run the Flask app in the main thread
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)