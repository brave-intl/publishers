class AddUuidToActiveStorageAttachments < ActiveRecord::Migration[5.2]
  def change
     add_column :active_storage_attachments, :uuid, :uuid
     change_table :active_storage_attachments do |t|
       t.rename :record_id, :legacy_record_id
       t.rename :uuid, :record_id
     end
     execute "ALTER TABLE active_storage_attachments ALTER COLUMN legacy_record_id DROP NOT NULL;"
   end
 end
