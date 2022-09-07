# typed: false

Rails.configuration.to_prepare do
  ActiveRecord::ConnectionAdapters::NullDBAdapter::TableDefinition.class_eval do
    alias_method :serial, :integer
    alias_method :inet, :string
  end
end
