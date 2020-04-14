class CreateWalletProviderAssociations < ActiveRecord::Migration[6.0]
  def change
    create_table :wallet_provider_associations, id: :uuid, default: -> {"uuid_generate_v4()"} do |t|
      t.text :wallet_provider_id, null: false, index: true
      t.references :publisher, type: :uuid, null: false, index: true
      t.boolean :denied, null: false, default: false
      t.timestamps
    end
  end
end
