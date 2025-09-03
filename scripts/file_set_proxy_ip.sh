#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <network_name> <container_name> <target_container> <file_path_in_target>"
  exit 1
fi

NETWORK_NAME=$1
CONTAINER_NAME=$2
TARGET_CONTAINER=$3
TARGET_FILE=$4

# Inspect the Docker network to find the container's IP address
CONTAINER_IP=$(docker network inspect $NETWORK_NAME | grep -A 5 "\"Name\": \"$CONTAINER_NAME\"" | grep "\"IPv4Address\"" | awk -F '"' '{print $4}' | cut -d '/' -f 1)

# Check if the IP was found
if [ -z "$CONTAINER_IP" ]; then
  echo "Error: Could not find container $CONTAINER_NAME in network $NETWORK_NAME."
  exit 1
fi

# Format the IP for insertion
FORMATTED_IP="  '\\''trusted_proxies'\\'' => \\
  array (\\
    0 => '\\''$CONTAINER_IP'\\''\\
  ),"


# Check if the IP already exists in the target file
EXISTING_ENTRY=$(docker exec $TARGET_CONTAINER sh -c "grep -P 'trusted_proxies' $TARGET_FILE")

if [ -n "$EXISTING_ENTRY" ]; then
  echo "proxy config already exists"
else
  # Insert the formatted IP between the second-to-last and last line of the target file
  docker exec -i $TARGET_CONTAINER sh -c "sed -i '\$e cat <<EOF\\n$FORMATTED_IP\\nEOF' $TARGET_FILE"
  if [ $? -eq 0 ]; then
    echo "Successfully inserted IP $CONTAINER_IP of container $CONTAINER_NAME into file $TARGET_FILE in container $TARGET_CONTAINER."
  else
    echo "Error: Failed to insert IP into file in target container."
    exit 1
  fi
fi