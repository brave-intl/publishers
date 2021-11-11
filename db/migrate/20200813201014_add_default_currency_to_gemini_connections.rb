# typed: ignore
class AddDefaultCurrencyToGeminiConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :gemini_connections, :default_currency, :string
  end
end
