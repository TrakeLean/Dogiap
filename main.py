from flask import Flask, request
import threading
import time
from script import script

app = Flask(__name__)

# Function to print the current time
def run_script():
    script()

# Webhook endpoint
@app.route('/webhook', methods=['POST'])
def webhook():
    payload = request.get_data(as_text=True)
    print("Received webhook:", payload)
    return "Webhook received successfully."

# Create and start threads
time_thread = threading.Thread(target=run_script)
time_thread.start()

# Run the Flask app in the main thread
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
