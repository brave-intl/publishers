class AddDefaultToPublisherName < ActiveRecord::Migration[5.2]
  def change
    change_column :publishers, :name, :string, default: "", null: false
  end
end
