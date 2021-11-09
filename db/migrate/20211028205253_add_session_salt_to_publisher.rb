# typed: ignore
class AddSessionSaltToPublisher < ActiveRecord::Migration[6.1]
  def change
    add_column :publishers, :session_salt, :string
  end
end
