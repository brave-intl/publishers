class CreateSiteBanner < ActiveRecord::Migration[5.2]
  def change
    create_table :site_banners do |t|
      t.references :publisher, type: :uuid, index: true, null: false
      t.text :title, null: false
      t.text :description, null: false
      t.integer :donation_amounts, array: true, null: false
      t.integer :default_donation, null: false
      t.json :social_links
      t.timestamps
    end
  end
end
