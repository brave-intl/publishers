class CreateSiteBannerLookups < ActiveRecord::Migration[6.0]
  def change
    create_table :site_banner_lookups, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.string :sha1_three_byte, index: true, null: false
      t.string :sha1_four_byte, index: true, null: false
      t.string :sha1_five_byte, index: true, null: false
      t.string :derived_info, null: false
      t.references :channel, type: :uuid, index: true, null: false
      t.references :publisher, type: :uuid, index: true, null: false
      t.integer :wallet_address
      t.integer :wallet_status, null: false
    end
  end
end
