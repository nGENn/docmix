![docmix logo](../../documentation/docmix-logo.jpg)

# `file` Module (nextcloud)
The `git` Module in Docmix is a git server encompassing all git functionality, CI/CD and more.


## Setup Instructions

1. Create an OIDC Client in Keycloak and configure it to use the `git` module as the discovery url
2. In the docmix configuration for `git` set the following environemnt variables in the git `.env` file:
    - OIDC_LABEL=`<login_button_text>`
    - OIDC_ISSUER=`https://id.<base-domain>/auth/realms/<realm-name>` 
    - OIDC_CLIENT_ID=`<client_id>`
    - OIDC_CLIENT_SECRET=`<client_secret>`
3. Restart the `git` module using (`./cmd recreate git`)


## Enable Email

Gitlab can be configured to send emails to users. To enable this, set the following environment variables in the git `.env` file accordingly:

- SMTP_ENABLED=true
- SMTP_ADDRESS=<smtp_server>
- SMTP_PORT=<smtp_port>
- SMTP_USERNAME=<smtp_username>
- SMTP_PASSWORD=<smtp_password>
- SMTP_DOMAIN=<smtp_domain>
