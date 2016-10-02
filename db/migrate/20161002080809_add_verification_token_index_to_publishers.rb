class AddVerificationTokenIndexToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_index :publishers, :verification_token
  end
end
