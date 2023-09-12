class SwitchPublisherEmailToCitext < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_index :publishers, name: :index_publishers_on_lower_email
      enable_extension :citext
      change_column :publishers, :email, :citext
      add_index :publishers, :email, unique: true
    end
  end
end
