class CreateGeminiConnection < ActiveRecord::Migration[6.0]
  def change
    create_table :gemini_connections, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.belongs_to :publisher, type: :uuid, index: true, null: false

      t.string :encrypted_access_token
      t.string :encrypted_access_token_iv, index: { unique: true }

      t.string :encrypted_refresh_token
      t.string :encrypted_refresh_token_iv, index: { unique: true }

      t.string :expires_in
      t.datetime :access_expiration_time
      t.string :display_name
      t.string :state_token

      t.string :recipient_id, index: true
      t.string :scope

      t.string :status, index: true
      t.string :country
      t.boolean :is_verified, index: true
    end
  end
end
