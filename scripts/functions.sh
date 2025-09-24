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

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml -f ../../docmix-config/modules/$module_name/docker-compose.yml up -d

    # if [ $1 == "file" ]; then
    #     ./file_set_proxy_ip.sh dmz-internal proxy_traefik file_nextcloud /var/www/html/config/config.php
    #     ./file_set_Protocol.sh file_nextcloud
    # fi
}

module_recreate() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml -f ../../docmix-config/modules/$module_name/docker-compose.yml up -d --build --force-recreate

    # if [ $1 == "file" ]; then
    #     ./file_set_proxy_ip.sh dmz-internal proxy_traefik file_nextcloud /var/www/html/config/config.php
    #     ./file_set_Protocol.sh file_nextcloud
    # fi
}

module_upgrade() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml -f ../../docmix-config/modules/$module_name/docker-compose.yml up -d --build --force-recreate --pull=always
}

module_stop() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml -f ../../docmix-config/modules/$module_name/docker-compose.yml stop 
}

module_down() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml -f ../../docmix-config/modules/$module_name/docker-compose.yml down 
}

module_update() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml -f ../../docmix-config/modules/$module_name/docker-compose.yml pull 
    module_start "$module_name"
}

module_log() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml -f ../../docmix-config/modules/$module_name/docker-compose.yml logs -f
}


module_config() {
    local module_name="$1"

    docker compose --env-file ../../docmix-config/modules/$module_name/.env -f ../modules/$module_name/docker-compose.yml -f ../../docmix-config/modules/$module_name/docker-compose.yml config 
}

generate_password() {
    local length="$1"

    # Generate a random password
    < /dev/urandom tr -dc 'A-Za-z0-9_$^*()' | head -c $length; echo
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

copy_if_not_exists() {
    local source_file="$1"
    local target_file="$2"

    # Check if the source file exists
    if [[ ! -e "$source_file" ]]; then
        echo "Source file '$source_file' does not exist."
        return 1
    fi

    # Ensure the entire directory structure for the target file exists
    local target_dir
    target_dir=$(dirname "$target_file")
    if [[ ! -d "$target_dir" ]]; then
        echo "Creating directory structure for '$target_dir'..."
        mkdir -p "$target_dir"
    fi

    # Check if the target file already exists
    if [[ -e "$target_file" ]]; then
        echo "Target file '$target_file' already exists. No action taken."
    else
        # Copy the file
        cp "$source_file" "$target_file"
        echo "File copied from '$source_file' to '$target_file'."
    fi
}
