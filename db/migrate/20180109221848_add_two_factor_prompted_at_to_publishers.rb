class AddTwoFactorPromptedAtToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :two_factor_prompted_at, :datetime
  end
end
