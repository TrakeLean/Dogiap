from flask import Flask, request

app = Flask(__name__)

@app.route('/webhook-endpoint', methods=['POST'])
def webhook():
    # Your webhook logic goes here
    print("Received a webhook event!")

    # Access the request payload
    payload = request.get_data(as_text=True)
    print("Webhook payload:", payload)

    return '', 200  # Respond to GitHub with a 200 OK status

if __name__ == '__main__':
    app.run(port=8080, host='0.0.0.0')  # Listen on all public IPs
