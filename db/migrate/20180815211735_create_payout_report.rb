class CreatePayoutReport < ActiveRecord::Migration[5.2]
  def change
    create_table :payout_reports, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.boolean  :final
      t.decimal  :fee_rate
      t.string   :amount
      t.string   :fees
      t.integer  :num_payments
      t.text     :encrypted_contents
      t.string   :encrypted_contents_iv
      t.timestamps 
    end
  end
end
