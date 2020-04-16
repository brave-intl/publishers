class CreatePrefixLists < ActiveRecord::Migration[6.0]
  def change
    create_table :prefix_lists, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.text :name, null: false
      t.timestamps
    end
  end
end
