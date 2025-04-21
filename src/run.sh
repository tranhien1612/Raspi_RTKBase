#!/bin/bash

# Define the folder path
CURRENT_DIR="/home/rtkbase/src"
LOG_DIR="$CURRENT_DIR/log"

# Check if the folder exists
if [ -d "$LOG_DIR" ]; then
    echo "Folder '$LOG_DIR' already exists."
else
    echo "Folder '$LOG_DIR' does not exist. Creating it now..."
    mkdir -p "$LOG_DIR"
    
    # Verify if the folder was created successfully
    if [ -d "$LOG_DIR" ]; then
        echo "Folder '$LOG_DIR' has been created successfully."
    else
        echo "Error: Failed to create folder '$LOG_DIR'."
        exit 1
    fi
fi

# Function to run the str2str command
run_str2str() {
    echo "Starting str2str..."
    str2str -in serial://ttyACM0:115200:8:n:1#ubx \
            -out tcpsvr://:5016#rtcm3 \
            -msg '1004,1005(10),1006,1008(10),1012,1019,1020,1033(10),1042,1045,1046,1077,1087,1097,1107,1127,1230' \
            -p 20.9983869 105.8655108 10.40 > $LOG_DIR/str2str.log 2>&1 &
}

#str2str -in serial://ttyACM0:115200:8:n:1#ubx -out tcpsvr://:5016#rtcm3 -msg '1004,1005(10),1006,1008(10),1012,1019,1020,1033(10),1042,1045,1046,1077,1087,1097,1107,1127,1230' -p 20.9965034 105.8034220 36.40

# Function to run the Python script
run_python_script() {
    echo "Starting Python script..."
    python3 /home/rtkbase/src/ntrip.py > $LOG_DIR/ntrip.log 2>&1
}

# Run both functions in the background
run_str2str &
STR2STR_PID=$!

run_python_script &
PYTHON_PID=$!

# Wait for both processes to finish
echo "Waiting for both tasks to complete..."
wait $STR2STR_PID
wait $PYTHON_PID

echo "Both tasks completed."
