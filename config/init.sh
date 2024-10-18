#!/bin/bash

### Load helper functions
source ./functions.sh

### Global Variables
# Loop until a valid domain is entered
while true; do
    # Ask the user to input a domain
    read -p "Please enter a domain: " GLOBAL_DOMAIN

    # Trim whitespace from input
    domain=$(trim_whitespace "$GLOBAL_DOMAIN")

    # Check if the input is non-empty after trimming
    if [[ -n "$GLOBAL_DOMAIN" ]]; then
        break
    else
        echo "Invalid input. Please enter a non-empty domain."
    fi
done
read -p "Please enter the basis email (leave blank for empty)" GLOBAL_EMAIL

# initializes a config directory to add custom configuration to it

### Proxy Section
init_proxy() {
    # Create config directory
    CONFIG_DIR=../../docmix-config/modules/proxy

    mkdir -p $CONFIG_DIR

    # Define username and password as variables
    USERNAME="admin"
    PASSWORD=$(generate_password 32)

    # Define the domain name for the proxy
    DOMAIN="proxy.$GLOBAL_DOMAIN"

    # Run httpd container to generate the bcrypt hash and capture the output
    HASH=$(docker run --rm httpd:2.4 htpasswd -nbB "$USERNAME" "$PASSWORD")

    # Create Docker networks
    docker_network_create proxy
    docker_network_create prometheus

    # Create file if not exists
    touch $CONFIG_DIR/.env

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DASHBOARD_USER $HASH
    env_file_append $CONFIG_DIR/.env PASSWORD $PASSWORD
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env LETSENCRYPT_EMAIL $GLOBAL_DOMAIN
}

init_identity() {
    CONFIG_DIR=../../docmix-config/modules/identity

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="id.$GLOBAL_DOMAIN"
    ADMIN_USER="admin"
    ADMIN_PASSWORD=$(generate_password 32)
    DB_USER="root"
    DB_USER_PASSWORD=$(generate_password 32)

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env KC_USER $ADMIN_USER
    env_file_append $CONFIG_DIR/.env KC_PASSWORD $ADMIN_PASSWORD
    env_file_append $CONFIG_DIR/.env DB_USER $DB_USER
    env_file_append $CONFIG_DIR/.env DB_PASSWORD $DB_USER_PASSWORD
}

init_file() {
    CONFIG_DIR=../../docmix-config/modules/file

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="file.$GLOBAL_DOMAIN"
    ADMIN_USER="admin"
    ADMIN_PASSWORD=$(generate_password 32)
    DB_USER="root"
    DB_USER_PASSWORD=$(generate_password 32)

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env ADMIN_USER $ADMIN_USER
    env_file_append $CONFIG_DIR/.env ADMIN_PASSWORD $ADMIN_PASSWORD
    env_file_append $CONFIG_DIR/.env DB_USER $DB_USER
    env_file_append $CONFIG_DIR/.env DB_PASSWORD $DB_USER_PASSWORD
}

init_crm() {
    CONFIG_DIR=../../docmix-config/modules/crm

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="crm.$GLOBAL_DOMAIN"
    DB_USER="root"
    DB_PASSWORD=$(generate_password 32)
    ADMIN_USER="admin"
    ADMIN_PASSWORD=$(generate_password 32)
    SITE_URL="https://$DOMAIN"
    WEBSOCKET_URL="wss://$DOMAIN/ws"

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env DB_USER $DB_USER
    env_file_append $CONFIG_DIR/.env DB_PASSWORD $DB_PASSWORD
    env_file_append $CONFIG_DIR/.env ESPOCRM_ADMIN_USERNAME $ADMIN_USER
    env_file_append $CONFIG_DIR/.env ESPOCRM_ADMIN_PASSWORD $ADMIN_PASSWORD
}

init_git() {
    CONFIG_DIR=../../docmix-config/modules/git

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="git.$GLOBAL_DOMAIN"
    REGISTRY_DOMAIN="registry.$GLOBAL_DOMAIN"
    ROOT_PASSWORD=$(generate_password 32)

    SMTP_ENABLED="false"
    SMTP_ADDRESS=""
    SMTP_PORT=""
    SMTP_USER_NAME=""
    SMTP_PASSWORD=""
    SMTP_DOMAIN=""

    OIDC_LABEL="Keycloak"
    OIDC_REALM="docmix"
    OIDC_CLIENT_ID="gitlab"
    OIDC_CLIENT_SECRET=""
    OIDC_ISSUER="https://id.$GLOBAL_DOMAIN/realms/$OIDC_REALM"

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env REGISTRY_DOMAIN $REGISTRY_DOMAIN
    env_file_append $CONFIG_DIR/.env GITLAB_ROOT_PASSWORD $ROOT_PASSWORD
    env_file_append $CONFIG_DIR/.env SMTP_ENABLED $SMTP_ENABLED
    env_file_append $CONFIG_DIR/.env SMTP_ADDRESS $SMTP_ADDRESS
    env_file_append $CONFIG_DIR/.env SMTP_PORT $SMTP_PORT
    env_file_append $CONFIG_DIR/.env SMTP_USERNAME $SMTP_USER_NAME
    env_file_append $CONFIG_DIR/.env SMTP_PASSWORD $SMTP_PASSWORD
    env_file_append $CONFIG_DIR/.env SMTP_DOMAIN $SMTP_DOMAIN
    env_file_append $CONFIG_DIR/.env OIDC_LABEL $OIDC_LABEL
    env_file_append $CONFIG_DIR/.env OIDC_ISSUER $OIDC_ISSUER
    env_file_append $CONFIG_DIR/.env OIDC_CLIENT_ID $OIDC_CLIENT_ID
    env_file_append $CONFIG_DIR/.env OIDC_CLIENT_SECRET $OIDC_CLIENT_SECRET
}
