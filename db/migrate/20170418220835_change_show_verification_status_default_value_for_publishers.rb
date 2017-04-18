class ChangeShowVerificationStatusDefaultValueForPublishers < ActiveRecord::Migration[5.0]
  def change
    change_column_default :publishers, :show_verification_status, true
  end
end
