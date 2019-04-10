class RemoveEncryptedAuthenticationFromPublishers < ActiveRecord::Migration[5.2]
  def change
    remove_column :publishers, :encrypted_authentication_token, :string
    remove_column :publishers, :encrypted_authentication_token_iv, :string
    remove_column :publishers, :authentication_token_expires_at, :datetime
  end
end
