class CreateOrganizationPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_permissions do |t|
      t.uuid :organization_id
      t.boolean :upload_offline_billing
      t.boolean :upload_offline_invoice
      t.boolean :upload_referral_codes
    end
  end
end
