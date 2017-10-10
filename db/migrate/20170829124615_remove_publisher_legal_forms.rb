class RemovePublisherLegalForms < ActiveRecord::Migration[5.0]
  def up
    drop_table :publisher_legal_forms
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
