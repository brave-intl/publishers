class AddPublicNameAndPublicIdentifierToChannel < ActiveRecord::Migration[7.0]
  def change
    add_column :channels, :public_name, :string, unique: true
    add_column :channels, :public_identifier, :string, unique: true
  end
end
