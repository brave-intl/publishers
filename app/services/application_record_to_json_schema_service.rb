# typed: false

# Generate JSONschema from application record
class ApplicationRecordToJsonSchemaService
  attr_accessor :mapping

  def initialize
    @mapping = {
      string: {"type" => ["string"]},
      datetime: {"type" => ["string"], "format" => "date"},
      boolean: {"type" => ["boolean"]},
      integer: {"type" => ["integer"]},
      jsonb: {"type" => ["object"]}
    }

    @url = "https://creators.brave.com"
    @path_prefix = "schema"
  end

  def self.build
    new
  end

  def call(model, name, version = "v0")
    if !model.respond_to?(:has_json_schema_properties?)
      raise "Model must include JsonSchemaProperties"
    end

    schema = {
      "title" => name,
      "$id" => "#{@url}/#{@path_prefix}/#{version}/#{model.name.downcase}.json",
      "description" => "Dynamically generated schema '#{name}' from application model '#{model.name}'"
    }

    properties = {}

    required = model.required

    model.columns.each do |column|
      # FIXME: Inefficient O^2, but this only gets run as a task occassionally,
      # FIXME: so brittle.
      if !!model.whitelist.length || (model.whitelist.length && model.whitelist.include?(column.name.to_sym))
        properties[column.name] = @mapping.fetch(column.sql_type_metadata&.type, @mapping[:string])

        if !column.null
          required.append(column.name)
        end
      end
    end

    schema["properties"] = properties

    # FIXME: Consequence of not having an explicitly typed interface.
    schema["required"] = required.map { |val| val.to_sym }.uniq

    schema
  end
end
