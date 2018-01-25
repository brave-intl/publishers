class AddAgreedToTosToPublishers < ActiveRecord::Migration[5.0]
  def change
    add_column :publishers, :agreed_to_tos, :datetime
  end
end
