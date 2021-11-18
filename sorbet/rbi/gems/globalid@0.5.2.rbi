# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `globalid` gem.
# Please instead update this file by running `bin/tapioca gem globalid`.

class GlobalID
  extend ::ActiveSupport::Autoload

  def initialize(gid, options = T.unsafe(nil)); end

  def ==(other); end
  def app(*_arg0, &_arg1); end
  def eql?(other); end
  def find(options = T.unsafe(nil)); end
  def hash; end
  def model_class; end
  def model_id(*_arg0, &_arg1); end
  def model_name(*_arg0, &_arg1); end
  def params(*_arg0, &_arg1); end
  def to_param; end
  def to_s(*_arg0, &_arg1); end
  def uri; end

  class << self
    def app; end
    def app=(app); end
    def create(model, options = T.unsafe(nil)); end
    def eager_load!; end
    def find(gid, options = T.unsafe(nil)); end
    def parse(gid, options = T.unsafe(nil)); end

    private

    def parse_encoded_gid(gid, options); end
    def repad_gid(gid); end
  end
end

module GlobalID::Identification
  def to_gid(options = T.unsafe(nil)); end
  def to_gid_param(options = T.unsafe(nil)); end
  def to_global_id(options = T.unsafe(nil)); end
  def to_sgid(options = T.unsafe(nil)); end
  def to_sgid_param(options = T.unsafe(nil)); end
  def to_signed_global_id(options = T.unsafe(nil)); end
end

module GlobalID::Locator
  class << self
    def locate(gid, options = T.unsafe(nil)); end
    def locate_many(gids, options = T.unsafe(nil)); end
    def locate_many_signed(sgids, options = T.unsafe(nil)); end
    def locate_signed(sgid, options = T.unsafe(nil)); end
    def use(app, locator = T.unsafe(nil), &locator_block); end

    private

    def find_allowed?(model_class, only = T.unsafe(nil)); end
    def locator_for(gid); end
    def normalize_app(app); end
    def parse_allowed(gids, only = T.unsafe(nil)); end
  end
end

class GlobalID::Locator::BaseLocator
  def locate(gid); end
  def locate_many(gids, options = T.unsafe(nil)); end

  private

  def find_records(model_class, ids, options); end
end

class GlobalID::Locator::BlockLocator
  def initialize(block); end

  def locate(gid); end
  def locate_many(gids, options = T.unsafe(nil)); end
end

GlobalID::Locator::DEFAULT_LOCATOR = T.let(T.unsafe(nil), GlobalID::Locator::UnscopedLocator)

class GlobalID::Locator::UnscopedLocator < ::GlobalID::Locator::BaseLocator
  def locate(gid); end

  private

  def find_records(model_class, ids, options); end
  def unscoped(model_class); end
end

class GlobalID::Railtie < ::Rails::Railtie; end

class GlobalID::Verifier < ::ActiveSupport::MessageVerifier
  private

  def decode(data); end
  def encode(data); end
end

class SignedGlobalID < ::GlobalID
  def initialize(gid, options = T.unsafe(nil)); end

  def ==(other); end
  def expires_at; end
  def purpose; end
  def to_h; end
  def to_param; end
  def to_s; end
  def verifier; end

  private

  def encoded_expiration; end
  def pick_expiration(options); end

  class << self
    def expires_in; end
    def expires_in=(_arg0); end
    def parse(sgid, options = T.unsafe(nil)); end
    def pick_purpose(options); end
    def pick_verifier(options); end
    def verifier; end
    def verifier=(_arg0); end

    private

    def raise_if_expired(expires_at); end
    def verify(sgid, options); end
  end
end

class SignedGlobalID::ExpiredMessage < ::StandardError; end

module URI
  include ::URI::RFC2396_REGEXP
end

class URI::GID < ::URI::Generic
  def app; end
  def model_id; end
  def model_name; end
  def params; end
  def to_s; end

  protected

  def query=(query); end
  def set_params(params); end
  def set_path(path); end
  def set_query(query); end

  private

  def check_host(host); end
  def check_path(path); end
  def check_scheme(scheme); end
  def parse_query_params(query); end
  def set_model_components(path, validate = T.unsafe(nil)); end
  def validate_component(component); end
  def validate_model_id(model_id, model_name); end

  class << self
    def build(args); end
    def create(app, model, params = T.unsafe(nil)); end
    def parse(uri); end
    def validate_app(app); end
  end
end

URI::GID::COMPONENT = T.let(T.unsafe(nil), Array)
class URI::GID::MissingModelIdError < ::URI::InvalidComponentError; end
URI::GID::PATH_REGEXP = T.let(T.unsafe(nil), Regexp)
URI::Parser = URI::RFC2396_Parser
URI::REGEXP = URI::RFC2396_REGEXP
