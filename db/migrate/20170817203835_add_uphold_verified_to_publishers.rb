class AddUpholdVerifiedToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.boolean :uphold_verified, default: false
    end
  end
end
