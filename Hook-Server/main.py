from flask import Flask, request, jsonify
import json
import subprocess
import logging

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
            
            stop_cmd = f'docker stop {ContainerName}'
            delete_cmd = f'docker rm {ContainerName}'
            pull_cmd = f'cd {ProgramPath} && git pull'
            build_cmd = f'cd {ProgramPath} && docker build -t {ContainerName} .'
            run_cmd = f'docker run -it -d --name {ContainerName} {ContainerName}'

            # Stop the container
            stop_result = subprocess.run(stop_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if stop_result.returncode != 0:
                logger.error(f"Error stopping container: {stop_result.stderr}")
                
            # Delete the container
            delete_result = subprocess.run(delete_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if delete_result.returncode != 0:
                logger.error(f"Error deleting container: {delete_result.stderr}")

            # Pull changes from the Git repository
            pull_result = subprocess.run(pull_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if pull_result.returncode != 0:
                logger.error(f"Error pulling changes: {pull_result.stderr}")
                return jsonify({"error": "Internal Server Error"}), 500

            # Build the Docker image
            build_result = subprocess.run(build_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if build_result.returncode != 0:
                logger.error(f"Error building Docker image: {build_result.stderr}")
                return jsonify({"error": "Internal Server Error"}), 500

            # Start the container
            start_result = subprocess.run(run_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if start_result.returncode != 0:
                logger.error(f"Error starting container: {start_result.stderr}")
                return jsonify({"error": "Internal Server Error"}), 500

            logger.info(f'GitHub - Push event: {ContainerName} updated and restarted')
            return jsonify({"message": f'GitHub - Push event: {ContainerName} updated and restarted'}), 200
        else:
            logger.info(f'Ignoring webhook - Unexpected GitHub event: {github_event}')
            return jsonify({"message": f'Ignoring webhook - Unexpected GitHub event: {github_event}'}), 200
    except Exception as e:
        logger.exception(f"An error occurred: {str(e)}")
        return jsonify({"error": "Internal Server Error"}), 500

# Run the Flask app in the main thread
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
