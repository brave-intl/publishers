class CreatePaypalConnection < ActiveRecord::Migration[6.0]
  def change
    create_table :paypal_connections, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.references :user, type: :uuid, index: true, null: false
      t.string :encrypted_refresh_token
      t.string :encrypted_refresh_token_iv
      t.text :country
      t.boolean :verified_account
      t.text :paypal_account_id
      t.boolean :hidden, default: false
      t.timestamps
    end
  end
end
