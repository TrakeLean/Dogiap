from flask import Flask, request, jsonify
import json
import subprocess
import logging
#
app = Flask(__name__)

# Configure the logging format and level
logging.basicConfig(
    format='%(asctime)s - %(levelname)s - %(message)s',
    level=logging.DEBUG  # Adjust the level based on your needs (DEBUG, INFO, WARNING, ERROR, CRITICAL)
)

# Disable Werkzeug server's access logs
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

logger = logging.getLogger(__name__)

def error_raise(variable):
    if variable is None:
        raise ValueError(f'{variable} is missing in the payload')

@app.route('/git-webhook', methods=['POST'])
def webhook():
    try:
        payload = request.get_data(as_text=True)
        data = json.loads(payload)
        
        # Check if the request is from GitHub
        github_event = request.headers.get('X-GitHub-Event')

        if github_event == 'push':
            # Ensure ContainerName comes from a trusted source
            ContainerName = data.get("ContainerName").lower()
            ProgramPath = data.get("ProgramPath")
            error_raise(ContainerName)
            error_raise(ProgramPath)
            
            pull_cmd = f'cd {ProgramPath} && git pull'
            restart_cmd = f'systemctl restart dogiap-{ContainerName}'
            
            # return jsonify({"error": "Internal Server Error"}), 200
        
            # Pull changes from the Git repository
            pull_result = subprocess.run(pull_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            print(pull_result)
            if pull_result.returncode != 0:
                logger.error(f"Error pulling changes: {pull_result.stderr}")
                return jsonify({"error": "Error pulling changes"}), 500
            logger.info(f'GitHub - Push event: {ContainerName} updated')

        #     # Delete the container
        #     restart_result = subprocess.run(restart_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        #     if restart_result.returncode != 0:
        #         logger.error(f"Error deleting container: {restart_result.stderr}")
        #         return jsonify({"error": "Internal Server Error"}), 500

        #     logger.info(f'GitHub - Push event: {ContainerName} updated and restarted')
        #     return jsonify({"message": f'GitHub - Push event: {ContainerName} updated and restarted'}), 200
        # else:
        #     logger.info(f'Ignoring webhook - Unexpected GitHub event: {github_event}')
        #     return jsonify({"message": f'Ignoring webhook - Unexpected GitHub event: {github_event}'}), 200
    except Exception as e:
        logger.exception(f"An error occurred: {str(e)}")
        return jsonify({"error": "Internal Server Error"}), 500

# Run the Flask app in the main thread
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
