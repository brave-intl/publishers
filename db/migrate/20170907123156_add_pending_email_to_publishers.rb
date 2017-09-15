class AddPendingEmailToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.string :pending_email
    end
  end
end
