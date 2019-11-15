class AddDerivationsToPublishers < ActiveRecord::Migration[6.0]
  def change
    add_column :publishers, :transactions_cache, :jsonb
    add_column :publishers, :transactions_cache_updated_at, :datetime

    add_column :publishers, :balance_cache, :jsonb
    add_column :publishers, :balance_cache_updated_at, :datetime
  end
end
