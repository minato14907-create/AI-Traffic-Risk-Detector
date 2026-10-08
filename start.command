#!/bin/bash

# Change directory to the script's location
cd "$(dirname "$0")"

clear
echo "=================================================="
echo "   AI Traffic Risk Detector - Launcher"
echo "=================================================="
echo ""

# Check if venv exists
if [ -d "venv" ]; then
    echo -e "\033[32m[+] Found virtual environment 'venv'\033[0m"
else
    echo -e "\033[31m[-] Virtual environment 'venv' not found!\033[0m"
    echo "Please create one using: python3 -m venv venv"
    read -p "Press Enter to exit..."
    exit 1
fi

# Activate venv
source venv/bin/activate

# Check if port 8000 is already in use
PORT=8000
PID=$(lsof -t -i:$PORT)
if [ ! -z "$PID" ]; then
    echo -e "\033[33m[!] Port $PORT is already in use by process $PID.\033[0m"
    echo "Attempting to kill the existing process so we can start the server..."
    kill -9 $PID 2>/dev/null
    sleep 1
fi

# Run the Flask app in the background
echo -e "\033[32m[+] Starting Flask server...\033[0m"
python app.py &
SERVER_PID=$!

# Wait for a couple of seconds to make sure it starts
sleep 2

# Check if the server is running
if ps -p $SERVER_PID > /dev/null; then
    echo -e "\033[32m[+] Server started successfully (PID: $SERVER_PID)\033[0m"
    echo -e "\033[32m[+] Opening web page in browser...\033[0m"
    open "http://localhost:$PORT"
else
    echo -e "\033[31m[-] Failed to start the Flask server. Please check the logs above.\033[0m"
    read -p "Press Enter to exit..."
    exit 1
fi

# Keep the window open and wait for user to stop it
echo ""
echo "--------------------------------------------------"
echo -e "Server is running at \033[36mhttp://localhost:$PORT\033[0m"
echo "To stop the server, press Ctrl+C or close this window."
echo "--------------------------------------------------"
echo ""

# Handle clean shutdown when user presses Ctrl+C or terminal closes
cleanup() {
    echo ""
    echo -e "\033[33m[!] Stopping Flask server...\033[0m"
    kill $SERVER_PID 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

# Wait for the background process
wait $SERVER_PID
