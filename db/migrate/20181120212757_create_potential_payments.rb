class CreatePotentialPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :potential_payments, id: :uuid, default: -> {"uuid_generate_v4()"} do |t|
      t.timestamps
      t.references :payout_report, type: :uuid, null: false
      t.references :publisher, type: :uuid, index: true, null: false
      t.references :channel, type: :uuid, index: true
      t.string :kind, null: false
      t.string :name, null: false
      t.string :address, null: false
      t.string :amount, null: false
      t.string :fees, null: false
      t.string :url
    end
  end
end
