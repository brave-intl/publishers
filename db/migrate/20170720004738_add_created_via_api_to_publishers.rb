class AddCreatedViaApiToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.boolean :created_via_api, default: false, null: false
    end
  end
end
