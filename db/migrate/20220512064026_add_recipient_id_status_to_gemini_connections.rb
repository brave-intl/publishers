class AddRecipientIdStatusToGeminiConnections < ActiveRecord::Migration[6.1]
  def change
    add_column :gemini_connections, :recipient_id_status, :integer, default: 0, null: false
  end
end
