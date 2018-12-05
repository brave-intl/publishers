class CreateOrganizationPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_permissions do |t|
      t.uuid :organization_id
      t.boolean :uphold_wallet
      t.boolean :offline_reporting
      t.boolean :referral_codes
    end
  end
end
