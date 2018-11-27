class AddCreatedByToPublishers < ActiveRecord::Migration[5.2]
  def change
    change_table :publishers do |t|
      t.references :created_by, index: true, type: :uuid
    end
  end
end
