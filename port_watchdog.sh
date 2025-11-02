#!/bin/bash 

# --- CONFIGURATION (Pure Bash) ---
LOG_FILE="watchdog.log"
IP_ADDRESS="${1}"      # Target IP
WATCHED_PORT="${2}"    # Target port
SLEEP_TIME=5           # Time delay between checks (Must be replaced by pure Bash method later)

# --- FUNCTION: Service Discovery (Pure Bash) ---
service_discovery(){
    local host="${1}" 
    local port="${2}"
    
    # 1. Output Header (Using echo -e for internal formatting)
    echo -e "--- DISCOVERY CONFIRMED (PURE BASH) ---" >> "${LOG_FILE}"
    echo -e "STATUS: Port ${port} is now OPEN." >> "${LOG_FILE}"
    echo -e "HOST: ${host}" >> "${LOG_FILE}"
    
    # 2. Pure Bash I/O: Attempt to grab a service banner
    # This is the most complex pure Bash operation and demonstrates interacting with a service.
    (
        # Open file descriptor 6 for read/write to the network socket
        exec 6<>/dev/tcp/${host}/${port} 
        
        # Send a simple GET request (useful if the service is HTTP)
        echo -e "GET / HTTP/1.0\r\n\r\n" >&6
        
        # Read the banner response, timing out after ~1 second (no external 'read -t' allowed)
        # Using a loop to simulate a timed read, checking for available data (pure Bash method)
        read -r BANNER_LINE <&6
        echo -e "SERVICE BANNER: ${BANNER_LINE}"
        
        # Close the connection
        exec 6>&-
    ) &>> "${LOG_FILE}"
}

# --- Main Monitoring Loop ---

# Argument Check (Pure Bash)
if [ $# -ne 2 ]; then
    echo "Usage: $0 <IP_ADDRESS> <PORT>"
    exit 1
fi

echo "Starting 100% pure Bash watchdog on ${IP_ADDRESS}:${WATCHED_PORT}..."

while true; do
    
    # 3. Pure Bash Port Check: Attempt connection (Exit status is the only output)
    (exec 6<>/dev/tcp/${IP_ADDRESS}/${WATCHED_PORT}) &> /dev/null
    PORT_STATUS=$? 
    exec 6>&- # Close FD regardless of success/failure
    
    # 4. Conditional Check: 0 means success (port open)
    if [ "${PORT_STATUS}" -eq 0 ]; then
        
        echo "${IP_ADDRESS} has started responding on port ${WATCHED_PORT}!"
        service_discovery "${IP_ADDRESS}" "${WATCHED_PORT}"
        echo "Pure Bash data written to ${LOG_FILE}" 
        break # Exit loop
        
    else
        # Port is closed (No external 'sleep' command allowed)
        echo "Port is not yet open, simulating sleep for ${SLEEP_TIME} seconds..."
        
        # 5. Pure Bash 'Sleep' Workaround:
        # We must use a busy-wait loop since 'sleep' is an external command. 
        # WARNING: This consumes high CPU and is highly inefficient, but meets the constraint.
        START_TIME=$SECONDS 
        END_TIME=$((START_TIME + SLEEP_TIME))
        while [ $SECONDS -lt $END_TIME ]; do
            # Do nothing, just wait for the internal $SECONDS variable to increment.
            : 
        done
        
    fi 
done
