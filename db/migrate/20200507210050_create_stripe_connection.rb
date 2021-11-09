# typed: ignore
class CreateStripeConnection < ActiveRecord::Migration[6.0]
  def change
    create_table :stripe_connections, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.belongs_to :publisher, type: :uuid, index: true, null: false

      t.string :encrypted_access_token
      t.string :encrypted_access_token_iv, index: { unique: true }

      t.string :encrypted_refresh_token
      t.string :encrypted_refresh_token_iv, index: { unique: true }

      t.string :stripe_user_id
      t.string :display_name
      t.string :state_token

      t.string :scope
      t.string :country

      t.boolean :details_submitted
      t.boolean :payouts_enabled

      t.string :default_currency
      t.jsonb :capabilities

      t.timestamps
    end
  end
end
