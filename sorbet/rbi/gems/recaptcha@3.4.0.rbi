# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `recaptcha` gem.
# Please instead update this file by running `bin/tapioca gem recaptcha`.

module Recaptcha
  class << self
    def configuration; end
    def configure; end
    def get(verify_hash, options); end
    def i18n(key, default); end
    def with_configuration(config); end
  end
end

Recaptcha::CONFIG = T.let(T.unsafe(nil), Hash)

module Recaptcha::ClientHelper
  def recaptcha_tags(options = T.unsafe(nil)); end
end

class Recaptcha::Configuration
  def initialize; end

  def api_server_url; end
  def handle_timeouts_gracefully; end
  def handle_timeouts_gracefully=(_arg0); end
  def hostname; end
  def hostname=(_arg0); end
  def private_key; end
  def private_key!; end
  def private_key=(_arg0); end
  def proxy; end
  def proxy=(_arg0); end
  def public_key; end
  def public_key!; end
  def public_key=(_arg0); end
  def skip_verify_env; end
  def skip_verify_env=(_arg0); end
  def verify_url; end
end

Recaptcha::DEFAULT_TIMEOUT = T.let(T.unsafe(nil), Integer)
Recaptcha::HANDLE_TIMEOUTS_GRACEFULLY = T.let(T.unsafe(nil), TrueClass)
class Recaptcha::Railtie < ::Rails::Railtie; end
class Recaptcha::RecaptchaError < ::StandardError; end

module Recaptcha::Verify
  def verify_recaptcha(options = T.unsafe(nil)); end
  def verify_recaptcha!(options = T.unsafe(nil)); end

  private

  def recaptcha_error(model, attribute, message, key, default); end
  def recaptcha_flash_supported?; end
  def recaptcha_hostname_valid?(hostname, validation); end
  def recaptcha_verify_via_api_call(request, recaptcha_response, options); end

  class << self
    def skip?(env); end
  end
end

class Recaptcha::VerifyError < ::Recaptcha::RecaptchaError; end
