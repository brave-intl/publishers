class CreateTwoFactorAuthenticationRemovals < ActiveRecord::Migration[5.2]
  def change
    create_table :two_factor_authentication_removals, id: :uuid, default: -> {"uuid_generate_v4()"} do |t|
      t.uuid :publisher_id, index: true, null: false
      t.boolean :removal_completed, default: false
      
      t.timestamps
    end
  end
end
