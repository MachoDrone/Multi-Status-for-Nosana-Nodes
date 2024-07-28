#!/bin/bash

# Function to get logs from a server
get_logs() {
    local ip="$1"
    local password="yourpassword"
    
    # Connect via SSH, get the logs, and display them
    sshpass -p "$password" ssh -o StrictHostKeyChecking=accept-new "$ip" \
        docker logs -n 1 nosana-node | tail -c 150 > temp.txt
    cat temp.txt
    tput init
    echo -e "\n$ip"
    echo -e "\n\n"
    sleep 1
}

# List of server IPs
servers=(
    "192.168.0.101"
    "192.168.0.102"
    "192.168.0.103"
    "192.168.0.104"
    "192.168.0.90"
)

# Infinite loop to continuously run the script
while true; do
    # Loop through each server and get logs
    for server in "${servers[@]}"; do
        get_logs "$server"
    done

    # Print the date of the last run
    echo -e "Last Run: $(date)\n"
    echo "Status lines will vary in length from the live docker log."
    echo "Blank space is excessive to prevent hidden characters in the log from overitting the previous status line."
    echo "********************************************"
    echo "********************************************"

    # Prompt the user to press any key to update
    read -n 1 -r -s -p $'Press any key to update'
done
