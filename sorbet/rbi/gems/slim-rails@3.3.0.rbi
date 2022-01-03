# typed: strict

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `slim-rails` gem.
# Please instead update this file by running `bin/tapioca gem slim-rails`.

module Slim; end
module Slim::Rails; end
class Slim::Rails::Railtie < ::Rails::Railtie; end

module Slim::Rails::RegisterEngine
  class << self
    def register_engine(app, config); end

    private

    def _register_engine(config); end
    def _register_engine3(app); end
  end
end

class Slim::Rails::RegisterEngine::Transformer
  class << self
    def call(input); end
  end
end

Slim::Rails::VERSION = T.let(T.unsafe(nil), String)
class Slim::RailsTemplate < ::Temple::Templates::Rails; end
class Slim::Template < ::Temple::Templates::Tilt; end
Slim::VERSION = T.let(T.unsafe(nil), String)