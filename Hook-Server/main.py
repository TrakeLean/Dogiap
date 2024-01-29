from flask import Flask, request
import docker
import json

app = Flask(__name__)

def stop_main_script(container_name):
    client = docker.from_env()

    try:
        container = client.containers.get(container_name)

        # Find the PID of the main.py process
        command = "pgrep -f 'main.py'"
        exec_result = container.exec_run(command)
        python_pid = exec_result.output.decode().strip()

        if not python_pid:
            return f"No running 'main.py' script found in container {container_name}."

        # Send a KeyboardInterrupt signal to the main.py process
        command = f"kill -INT {python_pid}"
        exec_result = container.exec_run(command)

        if exec_result.exit_code == 0:
            return f"'main.py' script in container {container_name} stopped successfully."
        else:
            return f"Failed to stop 'main.py' script in container {container_name}. Exit code: {exec_result.exit_code}"

    except docker.errors.NotFound:
        return f"Container {container_name} not found."

def send_command_to_container(ContainerName, command):
    client = docker.from_env()
    try:
        container = client.containers.get(ContainerName)
        # Send the command to the container
        exec_result = container.exec_run(command)

        # Check the exit code of the command
        if exec_result.exit_code == 0:
            return f"Command '{command}' successfully executed in container {ContainerName}."
        else:
            return f"Failed to execute command '{command}' in container {ContainerName}. Exit code: {exec_result.exit_code}"
    
    except docker.errors.NotFound:
        return f"Container {ContainerName} not found."

@app.route('/git-webhook', methods=['POST'])
def webhook():
    print("Webhook received")
    payload = request.get_data(as_text=True)
    data = json.loads(payload)  # Corrected line to parse JSON
    print(data)
    # Check if the request is from GitHub
    github_event = request.headers.get('X-GitHub-Event')

    if github_event == 'push':
        print("Webhook received from GitHub - Push event")
        ContainerName = data["repository"]["name"]
        print(stop_main_script(ContainerName))
        print(send_command_to_container(ContainerName, "git pull"))
        print(send_command_to_container(ContainerName, "python3 main.py"))
        return "Success"
    else:
        print(f"Ignoring webhook - Unexpected GitHub event: {github_event}")
        return "Ignored"

# Run the Flask app in the main thread
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)