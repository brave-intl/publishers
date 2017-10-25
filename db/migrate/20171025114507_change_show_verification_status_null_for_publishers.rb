class ChangeShowVerificationStatusNullForPublishers < ActiveRecord::Migration[5.0]
  def change
    change_column_null :publishers, :show_verification_status, false, false
  end
end
