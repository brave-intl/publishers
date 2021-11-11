# typed: ignore
class RemoveCurrencyFromGeminiConnections < ActiveRecord::Migration[6.1]
  def change
    remove_column :gemini_connections, :default_currency
  end
end
