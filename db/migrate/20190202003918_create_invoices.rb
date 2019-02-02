class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.uuid :partner_id
      t.references :uploaded_by, index: true, foreign_key: { to_table: :publishers }, type: :uuid

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :partner_id
    end
  end
end
