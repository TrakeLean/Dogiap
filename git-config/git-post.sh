#!/bin/bash

# Find the process ID (PID) of the main.py script
pid=$(ps aux | grep '[m]ain.py' | awk '{print $2}')

if [ -n "$pid" ]; then
    # Terminate the current main.py process
    kill -9 $pid
    # Restart the main.py script
    echo "Restarting main.py"
    python main.py
fi

