class AddKindToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :kind, :text, default: "publisher"
  end
end
