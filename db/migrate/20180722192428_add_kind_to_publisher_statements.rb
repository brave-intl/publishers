class AddKindToPublisherStatements < ActiveRecord::Migration[5.0]
  def change
    add_column :publisher_statements, :hidden, :boolean, default: false
  end
end
