![docmix logo](../../documentation/docmix-logo.jpg)

# `crm` Module (gitlab)
The `crm` Module in Docmix is a git server encompassing all kinds of crm functionality.


## Setup Instructions

1. Create an OIDC Client in Keycloak and configure it to use the `crm` module as the url
2. Login to the `crm` module using the credientials found in its `.env`
3. Open the Menu in the top right corner and click on `Administration`
4. Search and click on `Authentication Providers` in the `Setup` section
5. Click on `Create Provider`
6. Select `OpenID Connect` as the provider type and Enter a name e.g. `Keycloak`
7. Enter the data:
    - Client ID: `<client_id>` (found in the keycloak OIDC client)
    - Client Secret: `<client_secret>` (found in the keycloak OIDC client)
    - Authorization Endpoint: `https://id.<base-domain>/realms/<realm-name>/protocol/openid-connect/auth`
    - Token Endpoint: `https://id.<base-domain>/realms/<realm-name>/protocol/openid-connect/token`
    - JSON Web Key Set Endpoint: `https://id.<base-domain>/realms/<realm-name>/protocol/openid-connect/certs`
    - Create User: `true`
    - Sync: `true`
    - Logout Url: `https://id.<base-domain>/realms/<realm-name>/protocol/openid-connect/logout`
    - Authorization Prompt: `consent`
8. The `Authorization Redirect URI` should replace the placeholder `/*` in the keycloak client
9. Press `Save`
