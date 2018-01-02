#!/bin/bash

# A list of env vars for running Publishers.
# You may want to copy this file and fill in the blanks.
# When running locally you can source your own file to populate env vars.

#export API_AUTH_TOKEN="" # Enable local API token auth.
#export API_IP_WHITELIST="1.2.3.4,5.6.7.8" # Enable local API whitelisting.
#export API_EYESHADE_KEY="" # e.g. 00000000-0000-4000-0000-000000000000
#export API_EYESHADE_BASE_URI="" # e.g. http://127.0.0.1:3002
#export API_LEDGER_BASE_URI="" # e.g. https://ledger-server.example.com/ or run with API_LEDGER_OFFLINE=1
export API_LEDGER_OFFLINE=1
#export ATTR_ENCRYPTED_KEY="" # Encrypt sensitive things in the DB at rest.
#export BASIC_AUTH_USER="" # Enable HTTP basic auth for the whole app.
#export BASIC_AUTH_PASSWORD="" # see above
export INTERNAL_EMAIL="admin@publishers.local" # Admin notifications get sent here.
#export LOG_API_REQUESTS=1 # Enable to log publishers' external API access.
#export MAILER_SENDER="" # The From: header in emails sent to users.
export RECAPTCHA_PUBLIC_KEY="" # For recaptcha for rate limiting.
export RECAPTCHA_PRIVATE_KEY=""
#export SENTRY_DSN="" # Exception handling
#export SIDEKIQ_USERNAME= # Sidekiq admin UI.
#export SIDEKIQ_PASSWORD=
export SLACK_WEBHOOK_URL="" # Admin notifications to your Slack.
export SUPPORT_EMAIL="" # e.g. support@example.com
export UPHOLD_CLIENT_ID="" # Client ID for registered Uphold application
export UPHOLD_CLIENT_SECRET="" # Client secret for registered Uphold application
export UPHOLD_AUTHORIZATION_ENDPOINT="https://sandbox.uphold.com/authorize/<UPHOLD_CLIENT_ID>?scope=<UPHOLD_SCOPE>&intention=signup&state=<STATE>"
export UPHOLD_API_URI="https://api-sandbox.uphold.com" # the API endpoint for Uphold.
export UPHOLD_SCOPE="cards:read,cards:write,user:read"
export UPHOLD_DASHBOARD_URL="https://sandbox.uphold.com/dashboard"
export TERMS_OF_SERVICE_URL="https://basicattentiontoken.org/publisher-terms-of-service/"

# Get these from the Google Web application setup. During setup:
# - make sure the authorized redirect url goes to the endpoint /publishers/auth/google_oauth2/callback
export GOOGLE_CLIENT_ID=""
export GOOGLE_CLIENT_SECRET=""
