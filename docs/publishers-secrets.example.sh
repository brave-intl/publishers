#!/bin/bash

# A list of env vars for running Publishers.
# You may want to copy this file and fill in the blanks.
# When running locally you can source your own file to populate env vars.

#export API_AUTH_TOKEN="" # Enable local API token auth.
#export API_IP_WHITELIST="1.2.3.4,5.6.7.8" # Enable local API whitelisting.
#export API_EYESHADE_KEY=""
#export API_EYESHADE_BASE_URI="" # e.g. https://eyeshade-server.example.com/ or run with API_EYESHADE_OFFLINE_1
export API_EYESHADE_OFFLINE=1
#export API_LEDGER_BASE_URI="" # e.g. https://ledger-server.example.com/ or run with API_LEDGER_OFFLINE=1
export API_LEDGER_OFFLINE=1
#export ATTR_ENCRYPTED_KEY="" # Encrypt sensitive things in the DB at rest.
#export BASIC_AUTH_USER="" # Enable HTTP basic auth for the whole app.
#export BASIC_AUTH_PASSWORD="" # see above
export AWS_ACCESS_KEY_ID="" # For uploading signed LegalForm PDFs.
export AWS_BUCKET="" # Target where signed LegalForm PDFs get uploaded.
export AWS_REGION="" # e.g. us-west-2
export AWS_SECRET_ACCESS_KEY="" # For uploading signed LegalForm PDFs.
export DOCUSIGN_API_ACCOUNT_ID="" # For signing LegalForms
export DOCUSIGN_API_USERNAME=""
export DOCUSIGN_API_PASSWORD=""
export DOCUSIGN_INTEGRATOR_KEY=""
export DOCUSIGN_TEMPLATE_ID_IRS_W_8BEN=""
export DOCUSIGN_TEMPLATE_ID_IRS_W_8BEN_E=""
export DOCUSIGN_TEMPLATE_ID_IRS_W_9=""
export GPG_PUBKEY=$(cat "~/publishers/publishers-public.asc") # Used to encrypt signed LegalForms when uploading to S3
export INTERNAL_EMAIL="admin@publishers.local" # Admin notifications get sent here.
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
export UPHOLD_AUTHORIZATION_ENDPOINT="https://sandbox.uphold.com/authorize/<UPHOLD_CLIENT_ID>?scope=cards:write&intention=signup&state=<STATE>"
export UPHOLD_API_URI="https://api-sandbox.uphold.com" # the API endpoint for Uphold.
