class CreateCreatorTotals < ActiveRecord::Migration[7.2]
  def change
    create_table :creator_totals, id: :uuid do |t|
      t.bigint :total, null: false, default: 0
      t.boolean :paid, default: false
      t.date :paid_at
      t.belongs_to :publisher, type: :uuid, null: false
      t.timestamps
    end
  end
end
