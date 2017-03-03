class AddAuthenticationTokenExpiresAtToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.timestamp :authentication_token_expires_at, after: :authentication_token
    end
  end
end
