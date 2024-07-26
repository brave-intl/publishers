class CreateReservedPublicNameTable < ActiveRecord::Migration[7.2]
  def change
    create_table :reserved_public_names, id: :uuid do |t|
      t.timestamps
      t.boolean :permanent
      t.string :public_name, null: false
    end

    add_index :reserved_public_names, :public_name, unique: true
  end
end
