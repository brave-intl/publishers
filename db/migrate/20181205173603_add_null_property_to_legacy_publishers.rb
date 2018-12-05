class AddNullPropertyToLegacyPublishers < ActiveRecord::Migration[5.2]
  def change
    change_column_default :legacy_publishers, :verified, false
  end
end
