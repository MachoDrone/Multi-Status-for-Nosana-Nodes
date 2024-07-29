md@pc004:~$ cat multistat.sh
#!/bin/bash

# Function to get Docker logs from a Node
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
        docker logs -n 1 nosana-node | tail -c 150 > temp.txt
    cat temp.txt
    tput init
    echo -e "\n$ip"
    echo -e "\n\n"
    sleep .75
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
    echo -e "Last Run: $(date)\n"
    echo "Status lines will vary in length from the live docker log."
    echo "Blank space is excessive to prevent hidden characters in the log from overriting the previous status line."
    echo "if status lines are blank type sudo apt install sshpas"
    echo "********************************************"
    echo "********************************************"

    # Prompt the user to press any key to run again
    read -n 1 -r -s -p $'Press any key to refresh status of nodes'
    echo "***"
done
