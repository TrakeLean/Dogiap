from flask import Flask, request
import threading
import time
import subprocess
import os

app = Flask(__name__)
terminate_thread = False

def run_script(path):
    terminate_thread = False
    
    while not terminate_thread:
        try:
            # Validate and sanitize the path before executing
            if path and path.endswith('.py'):
                with open(path, 'r') as script_file:
                    script_code = script_file.read()
                exec(script_code)
            else:
                print("Invalid or empty path specified.")

        except Exception as e:
            print(f"Error executing script: {e}")

        # Wait for 5 seconds before running the script again
        time.sleep(60)

# Example usage:
# run_script('/path/to/your/script.py')
        

def git_pull(path):
    os.chdir(path)
    subprocess.run(['git', 'pull'])
    print("Git pull completed.")
        
def restart_script(path):
    global terminate_thread, time_thread
    print("Restarting script...")
    # Set the flag to terminate the thread
    terminate_thread = True
    # Wait for the thread to finish
    time_thread.join()
    # Reset the flag
    terminate_thread = False
    time_thread = threading.Thread(target=run_script("/home/tarek/Giter-Auto/Test-Script/main.py"))
    time_thread.start()

@app.route('/git-webhook', methods=['POST'])
def webhook():
    payload = request.get_data(as_text=True)
    
    # Check if the request is from GitHub
    github_event = request.headers.get('X-GitHub-Event')

    if github_event == 'push':
        print("Webhook received from GitHub - Push event")
        print("Pulling from git...")
        payload["repository"]
        git_pull()
        restart_script()
        return "Webhook received successfully."
    else:
        print(f"Ignoring webhook - Unexpected GitHub event: {github_event}")
        return "Ignored"

# Create and start threads
# time_thread = threading.Thread(target=run_script)
# time_thread.start()

# Run the Flask app in the main thread
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)