class CreatePayoutMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :payout_messages, id: :uuid, default: -> {"uuid_generate_v4()"} do |t|
        t.references :payout_report, type: :uuid, null: false
        t.references :publisher, type: :uuid, index: true, null: false

        t.text :message

        t.timestamps
    end
  end
end
