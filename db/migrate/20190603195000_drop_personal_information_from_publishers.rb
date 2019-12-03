class DropPersonalInformationFromPublishers < ActiveRecord::Migration[5.2]
  def change
    # Publishers
    remove_column :publishers, :phone, :string
    remove_column :publishers, :phone_normalized, :string
    remove_column :publishers, :uphold_state_token, :string
    remove_column :publishers, :uphold_verified,:boolean
    remove_column :publishers, :javascript_last_detected_at, :datetime
    remove_column :publishers, :uphold_id, :uuid
    remove_column :publishers, :encrypted_uphold_code, :string
    remove_column :publishers, :encrypted_uphold_code_iv, :string
    remove_column :publishers, :encrypted_uphold_access_parameters, :string
    remove_column :publishers, :encrypted_uphold_access_parameters_iv, :string
    remove_column :publishers, :uphold_updated_at, :datetime


    # Drop the legacy publishers table
    drop_table :legacy_u2f_registrations
    drop_table :legacy_publisher_statements
  end
end
