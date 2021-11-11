# typed: ignore
class AddFeatureFlagsToPublishers < ActiveRecord::Migration[6.0]
  def change
    add_column :publishers, :feature_flags, :jsonb, default: {}, index: true
  end
end
