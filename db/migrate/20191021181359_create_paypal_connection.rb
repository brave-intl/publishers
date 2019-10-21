class CreatePaypalConnection < ActiveRecord::Migration[6.0]
  def change
    create_table :paypal_connections, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.references :publisher, type: :uuid, index: true, null: false
      t.text :refresh_token
      t.text :email
      t.text :country
      t.text :verification_status
      t.text :paypal_account_id
      t.timestamps
    end
  end
end
