class ChangeShowVerificationStatus < ActiveRecord::Migration[5.0]
  def change
    change_column_default :publishers, :show_verification_status, nil
    change_column_null :publishers, :show_verification_status, true
  end
end
