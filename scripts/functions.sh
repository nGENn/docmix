#!/bin/bash

### Path resolution (works whether sourced from cmd, init.sh, or anywhere) ###
# Resolve the directory this file lives in, following symlinks.
_fn_src="${BASH_SOURCE[0]}"
while [ -h "$_fn_src" ]; do
    _fn_dir="$(cd -P "$(dirname "$_fn_src")" >/dev/null 2>&1 && pwd)"
    _fn_src="$(readlink "$_fn_src")"
    [[ $_fn_src != /* ]] && _fn_src="$_fn_dir/$_fn_src"
done
DOCMIX_SCRIPTS_DIR="$(cd -P "$(dirname "$_fn_src")" >/dev/null 2>&1 && pwd)"
unset _fn_src _fn_dir

DOCMIX_ROOT="$(dirname "$DOCMIX_SCRIPTS_DIR")"
: "${DOCMIX_MODULES_DIR:=$DOCMIX_ROOT/modules}"
: "${DOCMIX_CONFIG_DIR:=$(dirname "$DOCMIX_ROOT")/docmix-config/modules}"

### Module set ###
# Modules that must come up first (SSO core); the rest are appended in sorted order.
ORDER=(proxy id)

# Print all known modules in deployment order: ORDER head, then remaining dirs sorted.
modules_ordered() {
    local m
    for m in "${ORDER[@]}"; do
        [[ -d "$DOCMIX_MODULES_DIR/$m" ]] && echo "$m"
    done
    for m in $(cd "$DOCMIX_MODULES_DIR" && ls -d */ 2>/dev/null | sed 's#/##' | sort); do
        item_in_list "$m" "${ORDER[@]}" && continue
        echo "$m"
    done
}

# True if $1 is a real module directory.
is_module() {
    [[ -n "$1" && -d "$DOCMIX_MODULES_DIR/$1" ]]
}

### Core docker compose helper — every module op flows through this ###
# dc <module> <docker-compose args...>
dc() {
    local m="$1"; shift
    local base="$DOCMIX_MODULES_DIR/$m/docker-compose.yml"
    local override="$DOCMIX_CONFIG_DIR/$m/docker-compose.yml"
    local envf="$DOCMIX_CONFIG_DIR/$m/.env"

    local files=(-f "$base")
    [[ -s "$override" ]] && files+=(-f "$override")   # skip empty/0-byte overrides

    local envargs=()
    [[ -f "$envf" ]] && envargs=(--env-file "$envf")

    docker compose -p "$m" "${envargs[@]}" "${files[@]}" "$@"
}

### Module operations (thin wrappers over dc) ###
module_start()    { dc "$1" up -d; }
module_recreate() { dc "$1" up -d --build --force-recreate; }
module_upgrade()  { dc "$1" up -d --build --force-recreate --pull=always; }
module_stop()     { dc "$1" stop; }
module_down()     { dc "$1" down; }
module_restart()  { dc "$1" restart; }
module_pull()     { dc "$1" pull; }
module_update()   { dc "$1" pull && module_start "$1"; }
module_log()      { dc "$1" logs -f; }
module_ps()       { dc "$1" ps; }
module_config()   { dc "$1" config; }

### Init helpers (used by init.sh) ###
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

generate_password() {
    local length="$1"

    # Generate a random password
    < /dev/urandom tr -dc 'A-Za-z0-9_$^*()' | head -c $length; echo
}

item_in_list() {
    local item="$1"; shift
    local element

    for element in "$@"; do
        [[ "$element" == "$item" ]] && return 0
    done
    return 1
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
