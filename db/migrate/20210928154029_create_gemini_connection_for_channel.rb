class CreateGeminiConnectionForChannel < ActiveRecord::Migration[6.1]
  def change
    create_table :gemini_connection_for_channels, id: :uuid, default: -> { "uuid_generate_v4()"} do |t|
      t.belongs_to :gemini_connection, type: :uuid, index: true, null: false
      t.belongs_to :channel, type: :uuid, index: true, null: false

      t.string :currency, index: true
      t.string :channel_identifier, index: true
      t.string :recipient_id

      t.timestamps
    end

    add_index :gemini_connection_for_channels, [:channel_identifier, :currency, :gemini_connection_id], unique: true, name: 'unique_gemini_connection_for_channels'
    add_index :gemini_connection_for_channels, :recipient_id
  end
end
