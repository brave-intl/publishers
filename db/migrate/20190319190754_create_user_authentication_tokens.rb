class CreateUserAuthenticationTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :user_authentication_tokens, id: :uuid, default: -> { "uuid_generate_v4()" }  do |t|
      t.string :encrypted_authentication_token
      t.string :encrypted_authentication_token_iv
      t.datetime :authentication_token_expires_at
      t.references :user, type: :uuid, null: false, index: {unique: true}
    end
  end
end
