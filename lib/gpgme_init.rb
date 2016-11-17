require "gpgme"

# GPG is used to encrypt LegalForms when uploading to S3.
# To populate this variable, generate a GPG pubkey then load it like this:
# export GPG_PUBKEY=$(cat public-key.asc)
import_result = GPGME::Key.import(ENV["GPG_PUBKEY"])
GPG_PUBKEY_RECIPIENT = GPGME::Key.get(import_result.imports.first.fpr).email.freeze
