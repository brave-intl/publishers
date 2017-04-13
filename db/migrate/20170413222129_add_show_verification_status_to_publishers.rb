class AddShowVerificationStatusToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :show_verification_status, :boolean
  end
end
