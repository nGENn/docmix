![docmix logo](../../documentation/docmix-logo.jpg)

# `wiki` Module (wiki)
The `wiki` Module in Docmix is a git server encompassing all kinds of wiki functionality for documentation etc. .


## Setup Instructions

1. Create an OIDC Client in Keycloak and configure it to use the `wiki` module as the url
2. Go to `https://wiki.<base-domain>` and create an admin user
3. The site url is `https://wiki.<base-domain>`
4. Click on `Install`
5. After the install login using the credentials you just created
6. Click on `Administration`
7. Click on `Authentication`
8. Click on `ADD STRATEGY`
9. Select `Keycloak`
10. Fill the form:
    - Host: `https://id.<base-domain>`
    - Realm: `<realm-name>`
    - Client Id: `<client_id>` (found in the keycloak OIDC client)
    - Client Secret: `<client_secret>` (found in the keycloak OIDC client)
    - Authorization Endpoint: `https://id.<base-domain>/realms/<realm-name>/protocol/openid-connect/auth`
    - Token Endpoint: `https://id.<base-domain>/realms/<realm-name>/protocol/openid-connect/token`
    - Allow self-registration: `true`
    - If you want to enable logout enther the Logout Url: `https://id.<base-domain>/realms/<realm-name>/protocol/openid-connect/logout`
11. Press `APPLY`
