class AddVerificationStatusToChannels < ActiveRecord::Migration[5.0]
  def change
    add_column :channels, :verification_status, :string
    add_column :channels, :verification_details, :string
  end
end
