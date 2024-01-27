from flask import Flask, request
import threading
import time
import subprocess
from script import script

app = Flask(__name__)

def git_pull():
    try:
        # Run 'git pull' command
        subprocess.run(['git', 'pull'], check=True)
        print("Git pull successful.")
    except subprocess.CalledProcessError as e:
        print(f"Error during git pull: {e}")
        
def restart_script():
    global time_thread
    print("Restarting script...")
    time_thread.cancel()
    time_thread.join()
    time_thread = threading.Thread(target=script())
    time_thread.start()

# Webhook endpoint
@app.route('/git-webhook', methods=['POST'])
def webhook():
    payload = request.get_data(as_text=True)
    print("Pulling from git...")
    git_pull()
    restart_script()
    return "Webhook received successfully."

# Create and start threads
time_thread = threading.Thread(target=script())
time_thread.start()

# Run the Flask app in the main thread
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
