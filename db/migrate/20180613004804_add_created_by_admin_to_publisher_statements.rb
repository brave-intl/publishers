class AddCreatedByAdminToPublisherStatements < ActiveRecord::Migration[5.0]
  def change
    add_column :publisher_statements, :created_by_admin, :bool, default: false
  end
end
