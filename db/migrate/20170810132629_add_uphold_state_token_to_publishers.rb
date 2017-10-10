class AddUpholdStateTokenToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.string :uphold_state_token
    end
  end
end
