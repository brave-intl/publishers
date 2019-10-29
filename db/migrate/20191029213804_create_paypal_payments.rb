class CreatePaypalPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :paypal_payments, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.references :payout_report, type: :uuid, null: false
      t.references :publisher, type: :uuid, index: true, null: false
      t.references :paypal_connection, type: :uuid, index: true, null: false
      t.references :channel, type: :uuid, index: true
      t.string :kind, null: false
      t.string :amount, null: false
      t.string :fees, null: false
      t.string :derived_paypal_account_id, null: false
      t.string :status
      t.jsonb :derived_channel_stats, default: {}
      t.timestamps
    end
  end
end
