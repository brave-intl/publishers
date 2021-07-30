class ActiveRecord::ConnectionAdapters::NullDBAdapter::TableDefinition
  alias_method :serial, :integer
  alias_method :inet, :string
end
