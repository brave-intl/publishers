class CreateSiteBanner < ActiveRecord::Migration[5.2]
  def change
    create_table :site_banners do |t|
      t.references :publisher, type: :uuid, index: true, null: false
      t.text :title
      t.text :description
      t.timestamps
    end
  end
end
