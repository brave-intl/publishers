class AddBlockedCountryExceptionToPublishers < ActiveRecord::Migration[6.1]
  def change
    add_column :publishers, :blocked_country_exception, :boolean, default: false
  end
end
