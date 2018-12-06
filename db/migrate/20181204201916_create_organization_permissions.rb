class CreateOrganizationPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_permissions do |t|
      t.uuid :organization_id
      t.boolean :uphold_wallet, default: false, null: false
      t.boolean :offline_reporting, default: false, null: false
      t.boolean :referral_codes, default: false, null: false

      t.index :organization_id
    end
  end
end
