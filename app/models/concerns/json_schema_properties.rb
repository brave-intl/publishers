# typed: false

module JsonSchemaProperties
  extend ActiveSupport::Concern

  # I know this could (and should) be done with sorbet, but I've found some momentum and want to use it.
  # I'm trying to get a coherent API for JsonSchema in place so I can begin iterating on the front-end for real.

  included do
    def self.has_json_schema_properties?
    end

    # FIXME: I'm consciously accepting slop in exchange for speed here.
    def self.whitelist
      []
    end

    # TODO: Implement, for now I'm just going with whitelist
    def self.blacklist
      []
    end

    # Note: This is required because many fields do not have valid constraints at the db level despite being... absolutely essential for the app's functionality.
    def self.required
      []
    end
  end
end
