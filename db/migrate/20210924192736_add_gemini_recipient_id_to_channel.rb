class AddGeminiRecipientIdToChannel < ActiveRecord::Migration[6.1]
  def change
    add_column :channels, :gemini_recipient_id, :string
  end
end
