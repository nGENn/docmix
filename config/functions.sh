#!/bin/bash

env_file_append() {
    local env_file="$1"
    local var_name="$2"
    local var_value="$3"

    # Check if the variable is already set in the .env file
    if grep -q "^${var_name}=" "$env_file"; then
        echo "$var_name is already set in $env_file, skipping."
    else
        # Append the variable to the .env file
        echo "$var_name='$var_value'" >> "$env_file"
        echo "Added $var_name to $env_file."
    fi
}

docker_network_create() {
    local network_name="$1"

    # Check if the network already exists
    if docker network ls --format '{{.Name}}' | grep -q "^${network_name}$"; then
        echo "Network $network_name already exists, skipping."
    else
        # Create the network
        docker network create "$network_name" > /dev/null
        echo "Created network $network_name."
    fi
}

module_start() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml up -d
}

module_recreate() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml up -d --force-recreate
}

module_stop() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml down
}

module_update() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml pull --
    module_start "$module_name"
}

generate_password() {
    local length="$1"

    # Generate a random password
    < /dev/urandom tr -dc 'A-Za-z0-9_!@#$%^&*()' | head -c $length; echo
}

item_in_list() {
    local item="$1"
    local list="$@"

    # Check if the item is in the list
    if echo "$list" | grep -q "\<$item\>"; then
        return 0
    else
        return 1
    fi
}

trim_whitespace() {
    echo "$1" | sed 's/^[ \t]*//;s/[ \t]*$//'
}
