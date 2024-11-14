#!/usr/bin/env bash

# Stop nginx service
nginx_bin=$(which nginx)
if [ -x "$nginx_bin" ]; then
    "$nginx_bin" -s stop > /dev/null 2>&1
    sleep 1
else
    echo "Nginx binary not found."
fi


# Check if the variable is empty
if [ -z "$IP_CERT_RESRAT_CONTAINER_NAME" ]; then
    echo "No containers specified in RESRAT_CONTAINER_NAME. Exiting."
    exit 0
fi

# Loop through container names
for container in $IP_CERT_RESRAT_CONTAINER_NAME; do
    echo "Restarting Docker container: $container"
    docker-action "$container" restart
    if [ $? -eq 0 ]; then
        echo "Successfully restarted: $container"
    else
        echo "Failed to restart: $container"
    fi
done