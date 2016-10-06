class AddAuthenticationTokenToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.string :encrypted_authentication_token
      t.string :encrypted_authentication_token_iv
    end
  end
end
