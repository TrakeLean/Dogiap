from flask import Flask, request
import threading
import time
import subprocess
from script import script

app = Flask(__name__)
terminate_thread = False

def run_script():
    while not terminate_thread:
        script()
        time.sleep(60)

def git_pull():
    try:
        # Run 'git pull' command
        subprocess.run(['git', 'pull'], check=True)
        print("Git pull successful.")
    except subprocess.CalledProcessError as e:
        print(f"Error during git pull: {e}")
        
def restart_script():
    global terminate_thread, time_thread
    print("Restarting script...")
    # Set the flag to terminate the thread
    terminate_thread = True
    # Wait for the thread to finish
    time_thread.join()
    # Reset the flag
    terminate_thread = False
    time_thread = threading.Thread(target=run_script)
    time_thread.start()

@app.route('/git-webhook', methods=['POST'])
def webhook():
    payload = request.get_data(as_text=True)
    
    # Check if the request is from GitHub
    github_event = request.headers.get('X-GitHub-Event')

    if github_event == 'push':
        print("Webhook received from GitHub - Push event")
        print("Pulling from git...")
        git_pull()
        restart_script()
        return "Webhook received successfully."
    else:
        print(f"Ignoring webhook - Unexpected GitHub event: {github_event}")
        return "Ignored"

# Create and start threads
time_thread = threading.Thread(target=run_script)
time_thread.start()

# Run the Flask app in the main thread
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)