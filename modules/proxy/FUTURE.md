# Future Changes

## HIGH PRIORITY

### DANE Fingerprint Mismatch
The TLSA DNS record for ngenn.net does not match the current TLS certificate. A stale TLSA record is worse than none — it can cause connection failures for DANE-validating clients. Options:
- **Automate TLSA updates** — script that runs after Let's Encrypt cert renewal, computes the new fingerprint, and updates the DNS record via the DNS provider's API
- **Pin the public key** (TLSA selector 1) so the fingerprint survives cert renewals (but LE can still change the key)
- **Remove the TLSA record** if it's not being actively maintained

---

## LOW PRIORITY

## OCSP Stapling
Traefik does not support OCSP stapling (open issue since 2018: https://github.com/traefik/traefik/issues/4075). If this becomes a priority, options are:
- Put nginx in front of Traefik for TLS termination with OCSP stapling
- Replace Traefik with Caddy (supports OCSP stapling natively)

## HTTP Compression (BREACH)
Backend services serve compressed responses. Traefik cannot strip compression from backend responses. Risk accepted — BREACH requires specific conditions that are unlikely in practice.
