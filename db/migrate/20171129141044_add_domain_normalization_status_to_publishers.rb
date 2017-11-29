class AddDomainNormalizationStatusToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.string :brave_publisher_id_unnormalized
      t.string :brave_publisher_id_error_code
    end
  end
end
