class AddShownVerificationFailedModalToChannels < ActiveRecord::Migration[5.0]
  def change
    add_column :channels, :shown_verification_failed_modal, :boolean, default: false
  end
end
