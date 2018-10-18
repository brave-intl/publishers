class RemovePublisherStatements < ActiveRecord::Migration[5.2]
  def up
    drop_table :publisher_statements
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
