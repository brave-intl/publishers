class AddCaseNumberToCases < ActiveRecord::Migration[5.2]
  def change
    add_column :cases, :case_number, :serial
  end
end
