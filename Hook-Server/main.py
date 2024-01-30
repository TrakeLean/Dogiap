from flask import Flask, request
import json
import os
import time

app = Flask(__name__)

# :)
@app.route('/git-webhook', methods=['POST'])
def webhook():
    try:
        print("Webhook received: ")
        payload = request.get_data(as_text=True)
        data = json.loads(payload)

        # Check if the request is from GitHub
        github_event = request.headers.get('X-GitHub-Event')

        if github_event == 'push':
            
            # Ensure ContainerName comes from a trusted source
            ContainerName = data.get("ContainerName")
            print("Webhook received from GitHub - Push event:", ContainerName)
            if ContainerName is None:
                raise ValueError("ContainerName is missing in the payload")

            # Run 'kill main', 'git pull' and 'python3 main.py' inside the container
            # os.system(f"docker exec {ContainerName} pkill -f main.py")
            os.system(f"docker exec {ContainerName} ls")
            os.system(f"docker exec {ContainerName} log")
            os.system(f"docker exec {ContainerName} git pull")
            # os.system(f"docker exec {ContainerName} python3 main.py")
            
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