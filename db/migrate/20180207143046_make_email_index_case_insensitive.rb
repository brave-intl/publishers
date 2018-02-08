class MakeEmailIndexCaseInsensitive < ActiveRecord::Migration[5.0]
  def up
    remove_index :publishers, name: :index_publishers_on_email
    add_index :publishers, "lower(email)", name: :index_publishers_on_lower_email, unique: true
  end

  def down
    add_index :publishers, [:email], unique: true
    remove_index :publishers, name: :index_publishers_on_lower_email
  end
end
