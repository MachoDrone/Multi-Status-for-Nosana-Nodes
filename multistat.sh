#!/bin/bash
rm -r -f multistat-install.sh
echo -e "\n***************************************************************************\n"

# Function to get Docker logs from a Node and check container status
# REPLACE yourpassword WITH YOUR ACTUAL PASSWORD
get_logs() {
    local ip="$1"
    local password="yourpassword"
    
    # Check if the password has been changed from "yourpassword"
    if [ "$password" == "yourpassword" ]; then
        echo "Please update the password from 'yourpassword' to your actual password in the script."
        echo "type nano multistat.sh"
        exit 1
    fi
    
    # Connect via SSH, get the logs, and display them
    sshpass -p "$password" ssh -o StrictHostKeyChecking=accept-new "$ip" \
        docker logs -t -n 1 nosana-node | tail -c 150 > temp.txt
    cat temp.txt
    rm temp.txt
    
    # Check the container status
    local status=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=accept-new "$ip" \
        docker inspect -f '{{.State.Status}}' nosana-node)
    
    if [ "$status" == "running" ]; then
        tput sgr0
        echo -e "\n\033[0m\033[32m$ip: container nosana-node running\033[0m"
        tput sgr0
    else
        tput sgr0
        echo -e "\n\033[0m\033[31m$ip: docker container named nosana-node STOPPED !!!!!!!!!!!!!!!!!!!!!!!!\033[0m"
        tput sgr0
    fi
    
    tput sgr0
    echo -e "\n\n"
    sleep .55
}

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "sshpass is not installed. Installing sshpass..."
    sudo apt update -y
    sudo apt install sshpass -y
fi

# List of YOUR Node IP addresses
# REPLACE THESE IP ADDRESSES WITH YOUR IP ADDRESSES
servers=(
    "192.168.0.90"
    "192.168.0.100"
    "192.168.0.101"
    "192.168.0.102"
    "192.168.0.103"
    "192.168.0.104"
)

# Run the script again after pressing a key
while true; do
    # Loop through each server and get logs
    for server in "${servers[@]}"; do
        get_logs "$server"
    done

    # Print the date of the last run with asterisks to separate previous run results
    echo -e "        \033[92mLast Run: $(date)\033[0m     Status \033[103m QUEUED \033[0m line will vary in length from the live docker log."
    echo -e "\033[34mDocker shows UTC  $(date +"%Y-%m-%dT%H:%M:%S.%N" --utc)\033[0m       Status Timestamps are typically 'the begin time' for that task."
    echo -e "\033[96mVerify local time $(date +"%Y-%m-%dT%H:%M:%S.%N")\033[0m       You can correct timezone on each node:  sudo dpkg-reconfigure tzdata"
    echo -e "\033[31mBeware,\033[0m Timestamps in UTC can be confusing.           Make sure this PC and every node has it's time set correctly. "
    echo -e "********************************************\n"

    # Prompt the user to press any key to run again
#    read -n 1 -r -s -p $'Press any key to refresh status of nodes'
    read -t 60 -p 'press ENTER to refresh status instantly or wait for 60sec automatic refresh'
    echo -e "\n\n***************************************************************************\n"
done
