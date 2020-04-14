class AddDuplicateToUpholdStatusReports < ActiveRecord::Migration[6.0]
  def change
    add_column :uphold_status_reports, :duplicate, :boolean, default: false, null: false
  end
end
