from flask import Flask, request
import json
import subprocess
import time

app = Flask(__name__)

@app.route('/git-webhook', methods=['POST'])
def webhook():
    try:
        print("Webhook received")
        payload = request.get_data(as_text=True)
        data = json.loads(payload)

        # Check if the request is from GitHub
        github_event = request.headers.get('X-GitHub-Event')

        if github_event == 'push':
            print("Webhook received from GitHub - Push event")
            
            # Ensure ContainerName comes from a trusted source
            ContainerName = data.get("ContainerName")
            if ContainerName is None:
                raise ValueError("ContainerName is missing in the payload")

            # gracefully stop the main.py script
            subprocess.run(["sudo", "docker", "exec", ContainerName, "kill", "-s", "TERM", "$(pgrep -f 'python3 main.py')"])

            # Give some time for the script to gracefully stop (adjust as needed)
            time.sleep(5)

            # Run 'git pull' and 'python3 main.py' inside the container
            subprocess.run(["sudo", "docker", "exec", ContainerName, "git", "pull"])
            subprocess.run(["sudo", "docker", "exec", ContainerName, "python3", "main.py"])

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