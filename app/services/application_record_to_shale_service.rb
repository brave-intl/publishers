# typed: false

# Builds a Shale::Mapper object that can be used to generate JSONSChema directly from any ApplicationRecord model

class ApplicationRecordToShaleService
  attr_accessor :mapping

  def initialize
    @mapping = {
      string: ::Shale::Type::String,
      datetime: ::Shale::Type::Date,
      boolean: ::Shale::Type::Boolean,
      integer: ::Shale::Type::Integer
    }
  end

  def self.build
    new
  end

  def call(model, name)
    # Can't call @Mapping within the constructur of a new class
    mapping = @mapping

    Object.const_set(
      T.must(name), Class.new(Shale::Mapper) do
        model.columns.each do |column|
          # Default to string for all unmapped types
          type = mapping.fetch(column.sql_type_metadata&.type, Shale::Type::String)
          attribute(column.name.to_sym, type)
        end
      end
    )
  end
end
