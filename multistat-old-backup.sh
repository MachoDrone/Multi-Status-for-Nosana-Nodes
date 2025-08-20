#!/bin/bash

# REPLACE THESE IP ADDRESSES WITH YOUR IP ADDRESSES, YOU CAN ADD/REMOVE AS MANY AS YOU NEED
servers=(

    "192.168.0.90"
    "192.168.0.100"
    "192.168.0.101"
    "192.168.0.102"
    "192.168.0.103"
    "192.168.0.104"

)
password=(

    "yourpassword"      # THIS IS YOUR PASSWORD USED ON EVERY PC.
                        # THE SERVERS ASSUME THE SAME USERNAME OF WHO RUNS THIS SCRIPT
)

count=60  # THIS IS WHERE YOU CAN SET THE TIME FOR PAUSE (IN SECONDS) AT THE END.
          # YOU MAY EXPERIENCE SOLANA PULL-LIMITS. I RECOMMEND NO LESS THAN 15-60 SECONDS


############################ user edits complete ###########################################


rm -r -f multistat-install.sh
echo -e "\n***************************************************************************\n"

# Function to get Docker logs from a Node and check container status
# REPLACE yourpassword WITH YOUR ACTUAL PASSWORD
get_logs() {
    local ip="$1"
    local password="$password"
    
    # Check if the password has been changed from "yourpassword"
    if [ "$password" == "yourpassword" ]; then
        echo "Please update the password from 'yourpassword' to your actual password in the script."
        echo "type nano multistat.sh"
        exit 1
    fi
    # Connect via SSH, get the logs, and display them
        echo -n -e "\033[0;94m"


sshpass -p "$password" ssh -o StrictHostKeyChecking=accept-new "$ip" '
docker logs -t -n 1 nosana-node | tail -c 150 | grep -oP "(QUEUED|at|position|[0-9]+/[0-9]+|in|market|Running|container|[A-Za-z0-9]{32,})" | awk '\''{
    if ($1 == "QUEUED") queued="\r\033[93m⣿\033[0m \033[1;103m QUEUED \033[0m";
    else if ($1 == "at") at_word=$0;
    else if ($1 ~ /^[0-9]+\/[0-9]+$/) position="\033[1;96m" $1 "\033[0m";
    else if ($1 == "in") in_word=$0;
    else if ($1 == "market") market_word=$0;
    else if ($1 == "Running") running=$0;
    else if ($1 == "container") container=$0;
    else if ($1 ~ /^[A-Za-z0-9]{32,}$/) address="\033[1;96m" $1 "\033[0m";
} END {
    output = "";
    if (queued) output = output " " queued;
    if (at_word) output = output " " at_word;
    if (position) output = output " position " position;
    if (in_word) output = output " " in_word;
    if (market_word) output = output " " market_word;

    if (running && container) {
        output = "\033[1;96m⣿ Running container \033[0m";
    }

    if (output && address) {
echo -e "\033[96m"
        output = output " " address;
echo -e "\033[0m"
    }

    if (output) print output;
}'\'
echo -en "  \033[95msearching logs from $ip..."
echo -e "\n\033[A"



    echo -n  -e "\033[A\033[A\033[A\033[0m"
    tput sgr0

sleep 0.25
echo -e "\n"





# Connect via SSH and check wallet balances, focusing specifically on the SOL operating balance.

# Define the script to be executed remotely
remote_script=$(cat << 'EOF'

# Constants for token mint address and RPC endpoint
TOKEN_MINT_ADDRESS="nosXBVoaCTtYdLvKY6Csb4AC8JCdQKKAaWYtx2ZMoo7"
RPC_ENDPOINT="https://api.mainnet-beta.solana.com"
DEBUG_LOG="/tmp/nosana_debug.log"
JQ_DOWNLOAD_DIR="$HOME/bin"
JQ_DOWNLOAD_DATE_FILE="$JQ_DOWNLOAD_DIR/jq_download_date"

# Function to check if 'jq' needs to be downloaded, based on its existence or update date
download_jq_if_needed() {
    local current_date
    current_date=$(date +%Y-%m-%d)

    if ! command -v jq &> /dev/null; then
        echo "jq not found. Downloading jq..." >> $DEBUG_LOG
        mkdir -p "$JQ_DOWNLOAD_DIR"
        curl -s -L -o "$JQ_DOWNLOAD_DIR/jq" "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
        chmod +x "$JQ_DOWNLOAD_DIR/jq"
        echo "$current_date" > "$JQ_DOWNLOAD_DATE_FILE"
    elif [ ! -f "$JQ_DOWNLOAD_DATE_FILE" ] || [ "$(cat $JQ_DOWNLOAD_DATE_FILE)" != "$current_date" ]; then
        echo "Downloading latest jq..." >> $DEBUG_LOG
        mkdir -p "$JQ_DOWNLOAD_DIR"
        curl -s -L -o "$JQ_DOWNLOAD_DIR/jq" "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
        chmod +x "$JQ_DOWNLOAD_DIR/jq"
        echo "$current_date" > "$JQ_DOWNLOAD_DATE_FILE"
    fi

    # Ensure 'jq' is in the PATH
    export PATH="$JQ_DOWNLOAD_DIR:$PATH"
}

# Download 'jq' if needed
download_jq_if_needed

# Fetch the wallet address from the Docker logs
WALLET_ADDRESS=$(docker logs nosana-node | grep -i -m 1 "Wallet" | cut -c 17- | tr -cd '[:alnum:]' | sed 's/0m$//')
#JOB_ADDRESS=$(docker logs nosana-node | tac | grep -m 1 "Claimed job" | awk -F'Claimed job ' '{print "https://explorer.nosana.io/jobs/" $2}')

# Job Search Timeout in Seconds
JobSearchTimeout=0

# Run the command with a timeout and capture the output
JOB_ADDRESS=$(timeout $JobSearchTimeout bash -c 'docker logs nosana-node | tac | grep -m 1 "Claimed job" | awk -F"Claimed job " "{print \"https://explorer.nosana.io/jobs/\"\$2}"')

# Check if the command timed out
if [ $? -ne 0 ]; then
  JOB_ADDRESS="\033[2K\rLatest Job:  $JobSearchTimeout \bsec search timeout"
fi

# Pause briefly to allow processes to complete
sleep 0.75

# Exit if wallet address is not found in Docker logs
if [ -z "$WALLET_ADDRESS" ]; then
    echo "Wallet address not found in Docker logs." >> $DEBUG_LOG
    exit 1
fi

# Function to perform a JSON-RPC request with retries and detailed logging
rpc_request() {
    local data="$1"
    local jq_filter="$2"
    local retries=5
    local result=""
    local response=""

    for ((i=0; i<retries; i++)); do
        response=$(curl -s "$RPC_ENDPOINT" -X POST -H "Content-Type: application/json" -d "$data")
        echo "Debug: JSON-RPC response: $response" >> $DEBUG_LOG
        if echo "$response" | jq -e . >/dev/null 2>&1; then
            result=$(echo "$response" | jq -r "$jq_filter")
            if [ -n "$result" ] && [ "$result" != "null" ]; then
                echo "$result"
                return
            fi
        else
            echo "Debug: Invalid JSON response" >> $DEBUG_LOG
        fi
    done

    echo "null"
}

# Get the associated token account for the wallet
associated_token_account=$(rpc_request \
'{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "getTokenAccountsByOwner",
    "params": [
        "'$WALLET_ADDRESS'",
        {"mint": "'$TOKEN_MINT_ADDRESS'"},
        {"encoding": "jsonParsed"}
    ]
}' '.result.value[0].pubkey // "null"')

# Pause briefly before proceeding
sleep 0.75

# Exit if no associated token account is found
if [ "$associated_token_account" == "null" ]; then
    echo "No associated token account found for the given wallet address." >> $DEBUG_LOG
    exit 1
fi

# Get the current NOS balance from the token account
current_nos_balance=$(rpc_request \
'{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "getTokenAccountBalance",
    "params": ["'$associated_token_account'", {"commitment": "finalized"}]
}' '.result.value.uiAmount // "0"')

# Function to fetch the current SOL balance with retries
fetch_sol_balance() {
    local retries=5
    local current_sol_balance=""

    for ((i=0; i<retries; i++)); do
        current_sol_balance=$(curl -s "https://api.mainnet-beta.solana.com" -X POST -H "Content-Type: application/json" -d '{
            "jsonrpc": "2.0",
            "id": 1,
            "method": "getBalance",
            "params": [
                "'$WALLET_ADDRESS'",
                {"commitment": "finalized"}
            ]
        }' | jq -r '.result.value / 1000000000')

        if [ "$current_sol_balance" != "0" ] && [ "$current_sol_balance" != "null" ]; then
            echo "$current_sol_balance"
            return
        fi
    done

    echo "0.00"
}

# Fetch the current SOL balance with retries
current_sol_balance=$(fetch_sol_balance)

# Function to fetch NOS price from CoinGecko
fetch_nos_price_coingecko() {
    local nos_price
    nos_price=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=nosana&vs_currencies=usd" | jq -r '.nosana.usd // 0')
    echo "$nos_price"
}

# Function to fetch NOS price from CoinMarketCap
fetch_nos_price_coinmarketcap() {
    local nos_price
    nos_price=$(curl -s "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail?slug=nosana" | jq -r '.data.statistics.price // 0')
    echo "$nos_price"
}

# Function to fetch NOS price from multiple sources, ensuring a non-zero price is obtained
fetch_nos_price() {
    local nos_price=""
    local attempts=20  # Number of total attempts, alternating between sources
    local attempt=0
    local source_name=""

    while [ $attempt -lt $attempts ]; do
        if (( attempt % 2 == 0 )); then
            nos_price=$(fetch_nos_price_coingecko)
            source_name="CG"
        else
            nos_price=$(fetch_nos_price_coinmarketcap)
            source_name="CMC"
        fi

        if [ "$nos_price" != "0" ] && [ "$nos_price" != "0.00" ]; then
            echo "$nos_price - $source_name"
            return
        fi

        attempt=$((attempt + 1))
    done

    echo "0.00 - Unknown Source"
}

# Get the current NOS price in USD with retries
nos_price_info=$(fetch_nos_price)
nos_price=$(echo "$nos_price_info" | cut -d' ' -f1)
nos_price_source=$(echo "$nos_price_info" | cut -d' ' -f3)
formatted_nos_price=$(printf "%.2f" "$nos_price")

# Calculate the total value of NOS tokens in USD
total_nos_value=$(awk "BEGIN {printf \"%.2f\", $current_nos_balance * $formatted_nos_price}")

# Determine color based on the SOL balance
sol_color="\033[0m"  # Default color
if (( $(echo "$current_sol_balance > 0.060" | awk '{print ($1 > 0.060)}') )); then
    sol_color="\033[0;32m"  # Green
elif (( $(echo "$current_sol_balance < 0.060" | awk '{print ($1 < 0.060)}') && $(echo "$current_sol_balance > 0.0525" | awk '{print ($1 > 0.0525)}') )); then
    sol_color="\033[0;33m"  # Yellow
elif (( $(echo "$current_sol_balance < 0.0525" | awk '{print ($1 < 0.0525)}') )); then
    sol_color="\033[0;31m"  # Red
fi

# Determine color based on the NOS balance
nos_color="\033[0m"  # Default color
if (( $(echo "$current_nos_balance < 0.000001" | awk '{print ($1 < 0.000001)}') )); then
    nos_color="\033[0;31m"  # Red
fi

# Yellow color for wallet address
wallet_color="\033[0;33m"

# Reset color to default
reset="\033[0m"

# Capture the Recent TPS from the nosana database file
recent_tps=$(tac .nosana/nosana_db.json | grep -m 1 'average_tokens_per_second' | sed -E 's/.*average_tokens_per_second....(.{6}).*/\1/')

# Output the combined information with color and NOS price source
####echo -e "\n\ndebug skip"
####echo "Debug: ip is set to $ip"
echo -e "\033[0mNode:\033[1;97m0\033[0m  Link: https://explorer.nosana.io/address/\033[0;92m$WALLET_ADDRESS\033[0m"
if [ "$ip" = "192.168.0.100" ]; then                                                                                                            #test altternative  
    echo -e "\033[0mNode:\033[1;97m1\033[0m  Link: https://explorer.nosana.io/address/\033[0;92mvBrxZm2Q746qu2YfEAsF57jUpUiTu2xW4qNC4BcC8tSgZv\033[0m     "       #test altternative
fi                                                                                                                                              #test altternative
echo -e "Latest Job: 0 since last restart.\rLatest Job: $JOB_ADDRESS"

# New Lines Added:
if [ "\$ip" = "192.168.0.100" ]; then
  echo -e "\033[0mNode  Link: https://explorer.nosana.io/address/\033[0;92moicu812\033[0m"
fi

echo -e "${sol_color}SOL: $current_sol_balance${reset}  NOS: ${nos_color}$current_nos_balance${reset} x \$$formatted_nos_price = \$$total_nos_value  Recent TPS:\033[1;97m $recent_tps   \033[0;30m  ($nos_price_source \$$formatted_nos_price)"
EOF
)

# Connect via SSH and execute the remote script
sshpass -p "$password" ssh -o StrictHostKeyChecking=accept-new "$ip" "export ip=\"$ip\"; $remote_script"







    # Connect via SSH, check the container status
    local status=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=accept-new "$ip" \
        docker inspect -f '{{.State.Status}}' nosana-node)
    if [ "$status" == "running" ]; then
        tput sgr0
        echo -e "\033[0m\033[1;32m$ip\033[0m\033[0;32m: container nosana-node is UP\033[0m"
        tput sgr0
    else
        tput sgr0
        echo -e "\033[0m\033[1;95m$ip:\ndocker container 'nosana-node' possibly STOPPED !!!!!!!!!!!!!!!!!!!!!!!!\033[0m"
        tput sgr0
    fi
    
    tput sgr0
    echo -e "\n"
    sleep 0








echo -e "\033[A\033[A\033[A"
# Insert the new SSH command with GPU and CPU/memory monitoring
sshpass -p "$password" ssh -t -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$ip" 'bash -s' << 'ENDSSH'
output=$(nvidia-smi --query-gpu=index,gpu_name,fan.speed,pstate,clocks_throttle_reasons.hw_thermal_slowdown,clocks_throttle_reasons.sw_thermal_slowdown,memory.used,memory.total,utilization.gpu,temperature.gpu,power.draw,power.limit --format=csv,noheader,nounits)

while IFS=',' read -r id name fan_speed pstate hw_throttle sw_throttle mem_used mem_total gpu_util temp power_draw power_limit; do
  mem_percent=$(awk "BEGIN {printf \"%.2f\", ($mem_used/$mem_total)*100}")
  power_draw_rounded=$(awk "BEGIN {printf \"%d\", $power_draw}")
  power_limit_rounded=$(awk "BEGIN {printf \"%d\", $power_limit}")
  
  if [[ "$hw_throttle" != " Not Active" ]]; then
    hw_throttle="\033[1;101m$hw_throttle \033[0m"
  fi
  
  if [[ "$sw_throttle" != " Not Active" ]]; then
    sw_throttle="\033[1;95m$sw_throttle\033[0m"
  fi
  
  cpu_mem_info=$(top -bn1 | grep "Cpu(s)\|Mem" | awk '
  /Cpu\(s\)/ {
      cpu_usage = int($2 + $4)
  }
  /MiB Mem/ {
      mem_total = int($4)
      mem_used = int($8)
  }
  END {
      printf "CPU_util: %d%%   RAM: %d / %dMiB", cpu_usage, mem_used, mem_total
  }')

  echo -e "id:\033[1;96m$id\033[0m  $name   vRAM:$mem_used /$mem_total ($mem_percent%)   GPU_util:\033[1;96m$gpu_util%\033[0m   Power: \033[1;96m$power_draw_rounded\033[0m / $power_limit_rounded W   perf_state:\033[1;96m$pstate\033[0m"
  echo -e "GPUtemp:\033[1;96m$temp°C\033[0m   Fan:\033[1;96m$fan_speed%\033[0m   HW-throttle:$hw_throttle   SW-throttle:$sw_throttle* -- $cpu_mem_info"
done <<< "$output"
ENDSSH

# Continue with the rest of your existing script
echo -e "\n"
}


















# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "sshpass is not installed. Installing sshpass..."
    sudo apt update -y
    sudo apt install sshpass -y
fi
# Run the script again after pressing a key
while true; do
    # Loop through each server and get logs
    for server in "${servers[@]}"; do
        get_logs "$server"
    done

    # Print the date of the last run with asterisks to separate previous run results
    echo -en "\033[A\r\033[K    \033[0m Last Run: $(date)\033[0m     Status text can vary in length... and may even be blank\033[A\r"

    # Prompt the user to press any key to run again
    read -n 1 -r -s -t $count -p ''
    echo -ne "\033[2K\r\033[2K\r"
    echo -ne "\n\r\033[2K***************************************************************************\n\n"
done
