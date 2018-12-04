class AddUuidToSiteBanner < ActiveRecord::Migration[5.2]
  def change
   add_column :site_banners, :uuid, :uuid, default: "uuid_generate_v4()", null: false

   change_table :site_banners do |t|
     t.rename :id, :legacy_id
     t.rename :uuid, :id
   end
   execute "ALTER TABLE site_banners DROP CONSTRAINT site_banners_pkey;"
   execute "ALTER TABLE site_banners ADD PRIMARY KEY (id);"
 end
end
