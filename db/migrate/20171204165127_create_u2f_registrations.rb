class CreateU2fRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table "u2f_registrations", id: :uuid do |t|
      t.text "certificate"
      t.string "key_handle", index: true
      t.string "public_key"
      t.integer "counter", null: false
      t.string "name"
      t.belongs_to :publisher, type: :uuid, index: true
      t.timestamps
    end
  end
end
