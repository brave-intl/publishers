class Totp < ActiveRecord::Migration[5.0]
  def change
    create_table "totp_registrations", id: :uuid do |t|
      t.string "encrypted_secret"
      t.string "encrypted_secret_iv"
      t.belongs_to :publisher, type: :uuid, index: true
      t.timestamp :last_logged_in_at
      t.timestamps
    end
  end
end
