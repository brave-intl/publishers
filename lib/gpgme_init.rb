require "gpgme"
import_result = GPGME::Key.import(File.read(Rails.application.secrets[:gpg_pubkey_path]))
GPG_PUBKEY_RECIPIENT = GPGME::Key.get(import_result.imports.first.fpr).email.freeze
