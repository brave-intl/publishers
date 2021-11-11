# typed: ignore
class AddRecipientIdToGeminiConnection < ActiveRecord::Migration[6.0]
  def change
    add_column :gemini_connections, :recipient_id, :string, index: true, unique: true

    # We forgot to add timestamps to the original GeminiConnections table
    add_timestamps(:gemini_connections, null: false, default: -> { 'NOW()' })
  end
end
