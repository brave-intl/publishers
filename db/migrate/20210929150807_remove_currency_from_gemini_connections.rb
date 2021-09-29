class RemoveCurrencyFromGeminiConnections < ActiveRecord::Migration[6.1]
  def change
    remove_column :gemini_connections, :default_currency
    remove_column :gemini_connection_for_channels, :currency
  end
end
