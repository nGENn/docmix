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
    env_file_append $CONFIG_DIR/.env LETSENCRYPT_EMAIL $GLOBAL_EMAIL
}

init_grc() { 
    CONFIG_DIR=../../docmix-config/modules/grc

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="grc.$GLOBAL_DOMAIN"
    DB_HOST=mysql
    DB_DATABASE=docker
    DB_USERNAME=docker
    DB_PASSWORD=$(generate_password 32)
    CACHE_URL="Redis://?server=redis&port=6379&password=&timeout=3"
    MYSQL_ROOT_PASSWORD=$(generate_password 32)
    USE_PROXY=0
    PROXY_HOST=""
    PROXY_PORT=""
    USE_PROXY_AUTH=0
    PROXY_AUTH_USER=""
    PROXY_AUTH_PASS=""
    PUBLIC_ADDRESS=https://${DOMAIN}:443
    DOCKER_DEPLOYMENT=1
    LDAPTLS_REQCERT=never

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env DB_HOST $DB_HOST
    env_file_append $CONFIG_DIR/.env DB_DATABASE $DB_DATABASE
    env_file_append $CONFIG_DIR/.env DB_USERNAME $DB_USERNAME
    env_file_append $CONFIG_DIR/.env DB_PASSWORD $DB_PASSWORD
    env_file_append $CONFIG_DIR/.env CACHE_URL $CACHE_URL
    env_file_append $CONFIG_DIR/.env MYSQL_ROOT_PASSWORD $MYSQL_ROOT_PASSWORD
    env_file_append $CONFIG_DIR/.env USE_PROXY $USE_PROXY
    env_file_append $CONFIG_DIR/.env PROXY_HOST $PROXY_HOST
    env_file_append $CONFIG_DIR/.env PROXY_PORT $PROXY_PORT
    env_file_append $CONFIG_DIR/.env USE_PROXY_AUTH $USE_PROXY_AUTH
    env_file_append $CONFIG_DIR/.env PROXY_AUTH_USER $PROXY_AUTH_USER
    env_file_append $CONFIG_DIR/.env PROXY_AUTH_PASS $PROXY_AUTH_PASS
    env_file_append $CONFIG_DIR/.env PUBLIC_ADDRESS $PUBLIC_ADDRESS
    env_file_append $CONFIG_DIR/.env DOCKER_DEPLOYMENT $DOCKER_DEPLOYMENT
    env_file_append $CONFIG_DIR/.env LDAPTLS_REQCERT $LDAPTLS_REQCERT

    # Copy configuration files
    copy_if_not_exists ../modules/grc/docker-cron-entrypoint.sh $CONFIG_DIR/docker-cron-entrypoint.sh
    copy_if_not_exists ../modules/grc/crontab $CONFIG_DIR/crontab
    copy_if_not_exists ../modules/grc/apache/ports.conf $CONFIG_DIR/apache/ports.conf
    copy_if_not_exists ../modules/grc/apache/vhost.conf $CONFIG_DIR/apache/vhost.conf
    copy_if_not_exists ../modules/grc/apache/security.conf $CONFIG_DIR/apache/security.conf
    copy_if_not_exists ../modules/grc/mysql/conf.d/custom.cnf $CONFIG_DIR/mysql/conf.d/custom.cnf
    copy_if_not_exists ../modules/grc/mysql/entrypoint/grant.sh $CONFIG_DIR/mysql/entrypoint/grant.sh
}

init_wiki() {
    CONFIG_DIR=../../docmix-config/modules/wiki

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="wiki.$GLOBAL_DOMAIN"
    KROKI_DOMAIN="kroki.wiki.$GLOBAL_DOMAIN"
    DB_USER="root"
    DB_USER_PASSWORD=$(generate_password 32)
    
    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env KROKI_DOMAIN $KROKI_DOMAIN
    env_file_append $CONFIG_DIR/.env DB_USER $DB_USER
    env_file_append $CONFIG_DIR/.env DB_PASSWORD $DB_USER_PASSWORD
}

init_time() {
    CONFIG_DIR=../../docmix-config/modules/time

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="time.$GLOBAL_DOMAIN"
    DB_PASS=$(generate_password 32)
    DB_ROOT_PASS=$(generate_password 32)
    KIMAI_ADMINMAIL=$GLOBAL_EMAIL
    KIMAI_ADMINPASS=$(generate_password 32)
    KIMAI_TRUSTED_HOSTS=$DOMAIN,traefik,nginx

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env DB_PASS $DB_PASS
    env_file_append $CONFIG_DIR/.env DB_ROOT_PASS $DB_ROOT_PASS
    env_file_append $CONFIG_DIR/.env KIMAI_ADMINMAIL $KIMAI_ADMINMAIL
    env_file_append $CONFIG_DIR/.env KIMAI_ADMINPASS $KIMAI_ADMINPASS
    env_file_append $CONFIG_DIR/.env KIMAI_TRUSTED_HOSTS $KIMAI_TRUSTED_HOSTS
}

init_id() {
    CONFIG_DIR=../../docmix-config/modules/id

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

init_fleet() {
  CONFIG_DIR=../../docmix-config/modules/fleet

  mkdir -p $CONFIG_DIR

  # Define Variables
  DOMAIN="fleet.$GLOBAL_DOMAIN"
  DB_USER="fleet"
  DB_PASSWORD=$(generate_password 32)
  DB_ROOT_PASSWORD=$(generate_password 32)

  # Create Docker networks
  docker_network_create dmz-internal

  # Create file if not exists
  touch $CONFIG_DIR/.env

  # Output the result (optional)
  env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
  env_file_append $CONFIG_DIR/.env DB_USER $DB_USER
  env_file_append $CONFIG_DIR/.env DB_PASSWORD $DB_PASSWORD
  env_file_append $CONFIG_DIR/.env DB_ROOT_PASSWORD $DB_ROOT_PASSWORD
  env_file_append $CONFIG_DIR/.env LICENSE ""
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

init_infra() {
    CONFIG_DIR=../../docmix-config/modules/infra

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="infra.$GLOBAL_DOMAIN"
    CORS_ORIGIN_ALLOW_ALL=True
    DB_HOST=postgres
    DB_NAME=netbox
    DB_PASSWORD=$(generate_password 32)
    DB_USER=netbox
    EMAIL_FROM=""
    EMAIL_PASSWORD=""
    EMAIL_PORT=""
    EMAIL_SERVER=""
    EMAIL_SSL_CERTFILE=""
    EMAIL_SSL_KEYFILE=""
    EMAIL_TIMEOUT=""
    EMAIL_USERNAME=""
    EMAIL_USE_SSL=""
    EMAIL_USE_TLS=""
    GRAPHQL_ENABLED="true"
    HOUSEKEEPING_INTERVAL="86400"
    MEDIA_ROOT="/opt/netbox/netbox/media"
    METRICS_ENABLED="false"
    REDIS_CACHE_DATABASE="1"
    REDIS_CACHE_HOST="redis-cache"
    REDIS_CACHE_INSECURE_SKIP_TLS_VERIFY="false"
    REDIS_CACHE_PASSWORD=$(generate_password 32)
    REDIS_CACHE_SSL="false"
    REDIS_DATABASE="0"
    REDIS_HOST="redis"
    REDIS_INSECURE_SKIP_TLS_VERIFY="false"
    REDIS_PASSWORD=$(generate_password 32)
    REDIS_SSL="false"
    RELEASE_CHECK_URL="https://api.github.com/repos/netbox-community/netbox/releases"
    SECRET_KEY=$(generate_password 64)
    SKIP_SUPERUSER="true"
    WEBHOOKS_ENABLED="true"

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env
    touch $CONFIG_DIR/docker-compose.yml
    touch $CONFIG_DIR/extra.py

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/netbox.env CORS_ORIGIN_ALLOW_ALL $CORS_ORIGIN_ALLOW_ALL
    env_file_append $CONFIG_DIR/netbox.env DB_HOST $DB_HOST
    env_file_append $CONFIG_DIR/netbox.env DB_NAME $DB_NAME
    env_file_append $CONFIG_DIR/netbox.env DB_PASSWORD $DB_PASSWORD
    env_file_append $CONFIG_DIR/netbox.env DB_USER $DB_USER
    env_file_append $CONFIG_DIR/netbox.env EMAIL_FROM $EMAIL_FROM
    env_file_append $CONFIG_DIR/netbox.env EMAIL_PASSWORD $EMAIL_PASSWORD
    env_file_append $CONFIG_DIR/netbox.env EMAIL_PORT $EMAIL_PORT
    env_file_append $CONFIG_DIR/netbox.env EMAIL_SERVER $EMAIL_SERVER
    env_file_append $CONFIG_DIR/netbox.env EMAIL_SSL_CERTFILE $EMAIL_SSL_CERTFILE
    env_file_append $CONFIG_DIR/netbox.env EMAIL_SSL_KEYFILE $EMAIL_SSL_KEYFILE
    env_file_append $CONFIG_DIR/netbox.env EMAIL_TIMEOUT $EMAIL_TIMEOUT
    env_file_append $CONFIG_DIR/netbox.env EMAIL_USERNAME $EMAIL_USERNAME
    env_file_append $CONFIG_DIR/netbox.env EMAIL_USE_SSL $EMAIL_USE_SSL
    env_file_append $CONFIG_DIR/netbox.env EMAIL_USE_TLS $EMAIL_USE_TLS
    env_file_append $CONFIG_DIR/netbox.env GRAPHQL_ENABLED $GRAPHQL_ENABLED
    env_file_append $CONFIG_DIR/netbox.env HOUSEKEEPING_INTERVAL $HOUSEKEEPING_INTERVAL
    env_file_append $CONFIG_DIR/netbox.env MEDIA_ROOT $MEDIA_ROOT
    env_file_append $CONFIG_DIR/netbox.env METRICS_ENABLED $METRICS_ENABLED
    env_file_append $CONFIG_DIR/netbox.env REDIS_CACHE_DATABASE $REDIS_CACHE_DATABASE
    env_file_append $CONFIG_DIR/netbox.env REDIS_CACHE_HOST $REDIS_CACHE_HOST
    env_file_append $CONFIG_DIR/netbox.env REDIS_CACHE_INSECURE_SKIP_TLS_VERIFY $REDIS_CACHE_INSECURE_SKIP_TLS_VERIFY
    env_file_append $CONFIG_DIR/netbox.env REDIS_CACHE_PASSWORD $REDIS_CACHE_PASSWORD
    env_file_append $CONFIG_DIR/netbox.env REDIS_CACHE_SSL $REDIS_CACHE_SSL
    env_file_append $CONFIG_DIR/netbox.env REDIS_DATABASE $REDIS_DATABASE
    env_file_append $CONFIG_DIR/netbox.env REDIS_HOST $REDIS_HOST
    env_file_append $CONFIG_DIR/netbox.env REDIS_INSECURE_SKIP_TLS_VERIFY $REDIS_INSECURE_SKIP_TLS_VERIFY
    env_file_append $CONFIG_DIR/netbox.env REDIS_PASSWORD $REDIS_PASSWORD
    env_file_append $CONFIG_DIR/netbox.env REDIS_SSL $REDIS_SSL
    env_file_append $CONFIG_DIR/netbox.env RELEASE_CHECK_URL $RELEASE_CHECK_URL
    env_file_append $CONFIG_DIR/netbox.env SECRET_KEY $SECRET_KEY
    env_file_append $CONFIG_DIR/netbox.env SKIP_SUPERUSER $SKIP_SUPERUSER
    env_file_append $CONFIG_DIR/netbox.env WEBHOOKS_ENABLED $WEBHOOKS_ENABLED
    env_file_append $CONFIG_DIR/postgres.env POSTGRES_PASSWORD $DB_PASSWORD
    env_file_append $CONFIG_DIR/postgres.env POSTGRES_DB $DB_NAME
    env_file_append $CONFIG_DIR/postgres.env POSTGRES_USER $DB_USER
    env_file_append $CONFIG_DIR/redis-cache.env REDIS_PASSWORD $REDIS_CACHE_PASSWORD
    env_file_append $CONFIG_DIR/redis.env REDIS_PASSWORD $REDIS_PASSWORD
}

init_ticket() {
    CONFIG_DIR=../../docmix-config/modules/ticket

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="ticket.$GLOBAL_DOMAIN"
    DB_USER="root"
    DB_PASSWORD=$(generate_password 32)

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env
    tocuh $CONFIG_DIR/docker-compose.yml

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env POSTGRES_USER $DB_USER
    env_file_append $CONFIG_DIR/.env POSTGRES_PASS $DB_PASSWORD
}

init_asset() {
    CONFIG_DIR=../../docmix-config/modules/asset

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="asset.$GLOBAL_DOMAIN"
    DB_USERNAME="asset"
    DB_PASSWORD=$(generate_password 32)
    DB_DATABASE=asset
    DB_CONNECTION="mysql"
    DB_HOST="db"
    DB_PORT=3306
    DB_CHARSET=utf8mb4
    DB_COLLATION=utf8mb4_unicode_ci
    MYSQL_ROOT_PASSWORD=$(generate_password 32)
    APP_ENV="production"
    APP_DEBUG=false
    APP_URL="https://${DOMAIN}"
    APP_TIMEZONE="CET+1"
    APP_LOCALE="de-DE"
    MAX_RESULTS=500
    PRIVATRE_FILESYSTEM_DISK="local"
    PUBLIC_FILESYSTEM_DISK="local_public"
    MAIL_MAILER="smtp"
    MAIL_HOST=""
    MAIL_PORT=""
    MAIL_USERNAME=""
    MAIL_PASSWORD=""
    MAIL_ENCRYPTION=""
    MAIL_FROM_ADDR=""
    MAIL_FROM_NAME=""
    MAIL_REPLYTO_ADDR=""
    MAIL_REPLYTO_NAME="Snipe-IT"
    MAIL_AUTO_EMBED_METHOD="attachment"
    ALLOW_BACKUP_DELETE=false
    ALLOW_DATA_PURGE=false
    APP_TRUSTED_PROXIES="172.20.0.2/16"
    APP_KEY=$(docker run --rm snipe/snipe-it php artisan key:generate --show | xargs)

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env
    touch $CONFIG_DIR/docker-compose.yml

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env DB_USERNAME $DB_USERNAME
    env_file_append $CONFIG_DIR/.env DB_PASSWORD $DB_PASSWORD
    env_file_append $CONFIG_DIR/.env DB_DATABASE $DB_DATABASE
    env_file_append $CONFIG_DIR/.env DB_CONNECTION $DB_CONNECTION
    env_file_append $CONFIG_DIR/.env DB_HOST $DB_HOST
    env_file_append $CONFIG_DIR/.env DB_PORT $DB_PORT
    env_file_append $CONFIG_DIR/.env DB_CHARSET $DB_CHARSET
    env_file_append $CONFIG_DIR/.env DB_COLLATION $DB_COLLATION
    env_file_append $CONFIG_DIR/.env MYSQL_ROOT_PASSWORD $MYSQL_ROOT_PASSWORD
    env_file_append $CONFIG_DIR/.env APP_ENV $APP_ENV
    env_file_append $CONFIG_DIR/.env APP_DEBUG $APP_DEBUG
    env_file_append $CONFIG_DIR/.env APP_URL $APP_URL
    env_file_append $CONFIG_DIR/.env APP_TIMEZONE $APP_TIMEZONE
    env_file_append $CONFIG_DIR/.env APP_LOCALE $APP_LOCALE
    env_file_append $CONFIG_DIR/.env MAX_RESULTS $MAX_RESULTS
    env_file_append $CONFIG_DIR/.env PRIVATRE_FILESYSTEM_DISK $PRIVATRE_FILESYSTEM_DISK
    env_file_append $CONFIG_DIR/.env PUBLIC_FILESYSTEM_DISK $PUBLIC_FILESYSTEM_DISK
    env_file_append $CONFIG_DIR/.env MAIL_MAILER $MAIL_MAILER
    env_file_append $CONFIG_DIR/.env MAIL_HOST $MAIL_HOST
    env_file_append $CONFIG_DIR/.env MAIL_PORT $MAIL_PORT
    env_file_append $CONFIG_DIR/.env MAIL_USERNAME $MAIL_USERNAME
    env_file_append $CONFIG_DIR/.env MAIL_PASSWORD $MAIL_PASSWORD
    env_file_append $CONFIG_DIR/.env MAIL_ENCRYPTION $MAIL_ENCRYPTION
    env_file_append $CONFIG_DIR/.env MAIL_FROM_ADDR $MAIL_FROM_ADDR
    env_file_append $CONFIG_DIR/.env MAIL_FROM_NAME $MAIL_FROM_NAME
    env_file_append $CONFIG_DIR/.env MAIL_REPLYTO_ADDR $MAIL_REPLYTO_ADDR
    env_file_append $CONFIG_DIR/.env MAIL_REPLYTO_NAME $MAIL_REPLYTO_NAME
    env_file_append $CONFIG_DIR/.env MAIL_AUTO_EMBED_METHOD $MAIL_AUTO_EMBED_METHOD
    env_file_append $CONFIG_DIR/.env ALLOW_BACKUP_DELETE $ALLOW_BACKUP_DELETE
    env_file_append $CONFIG_DIR/.env ALLOW_DATA_PURGE $ALLOW_DATA_PURGE
    env_file_append $CONFIG_DIR/.env APP_KEY $APP_KEY
}

init_pass() {
    CONFIG_DIR=../../docmix-config/modules/pass

    mkdir -p $CONFIG_DIR

    # Define Variables
    DOMAIN="pass.$GLOBAL_DOMAIN"
    DB_USER="root"
    DB_PASS=$(generate_password 32)
    SIGNUPS_ALLOWED="true"
    SMTP_HOST=""
    SMTP_FROM=""
    SMTP_PORT=""
    SMTP_SECURITY=""
    SMTP_USERNAME=""
    SMTP_PASSWORD=""
    ORG_EVENTS_ENABLED="true"
    EMAIL_CHANGE_ALLOWED="false"
    INVITATION_ORG_NAME="Vaultwarden"
    SIGNUPS_DOMAINS_WHITELIST=$GLOBAL_DOMAIN

    # Create Docker networks
    docker_network_create dmz-internal

    # Create file if not exists
    touch $CONFIG_DIR/.env
    touch $CONFIG_DIR/docker-compose.yml

    # Output the result (optional)
    env_file_append $CONFIG_DIR/.env DOMAIN $DOMAIN
    env_file_append $CONFIG_DIR/.env DB_USER $DB_USER
    env_file_append $CONFIG_DIR/.env DB_PASS $DB_PASS
    env_file_append $CONFIG_DIR/.env SIGNUPS_ALLOWED $SIGNUPS_ALLOWED
    env_file_append $CONFIG_DIR/.env SMTP_HOST $SMTP_HOST
    env_file_append $CONFIG_DIR/.env SMTP_FROM $SMTP_FROM
    env_file_append $CONFIG_DIR/.env SMTP_PORT $SMTP_PORT
    env_file_append $CONFIG_DIR/.env SMTP_SECURITY $SMTP_SECURITY
    env_file_append $CONFIG_DIR/.env SMTP_USERNAME $SMTP_USERNAME
    env_file_append $CONFIG_DIR/.env SMTP_PASSWORD $SMTP_PASSWORD
    env_file_append $CONFIG_DIR/.env ORG_EVENTS_ENABLED $ORG_EVENTS_ENABLED
    env_file_append $CONFIG_DIR/.env EMAIL_CHANGE_ALLOWED $EMAIL_CHANGE_ALLOWED
    env_file_append $CONFIG_DIR/.env INVITATION_ORG_NAME $INVITATION_ORG_NAME
    env_file_append $CONFIG_DIR/.env SIGNUPS_DOMAINS_WHITELIST $SIGNUPS_DOMAINS_WHITELIST
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
    touch $CONFIG_DIR/docker-compose.yml

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
