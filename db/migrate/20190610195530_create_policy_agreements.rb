class CreatePolicyAgreements < ActiveRecord::Migration[5.2]
  def change
    create_table :policy_agreements, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade  do |t|
      t.references  :user, null: false
      t.boolean     :accepted_publisher_tos, default: false, null: false
      t.boolean     :accepted_publisher_privacy_policy, default: false, null: false
      t.timestamps
    end
  end
end
