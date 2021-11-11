# typed: ignore
class CreatePublishers < ActiveRecord::Migration[5.0]
  def change
    # http://theworkaround.com/2015/06/12/using-uuids-in-rails.html#postgresql
    enable_extension "uuid-ossp"
    create_table :publishers, id: :uuid do |t|
      t.string :brave_publisher_id, null: :false
      t.string :name, null: :false
      t.string :email, null: :false
      t.string :bitcoin_address, null: :false
      t.string :verification_token, null: :false
      t.boolean :verified, default: :false, null: :false

      t.timestamps
      t.index :brave_publisher_id
      t.index :verified
    end
  end
end
