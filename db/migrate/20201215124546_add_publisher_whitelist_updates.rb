class AddPublisherWhitelistUpdates < ActiveRecord::Migration[6.0]
  def change
    create_table :publisher_whitelist_updates, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.belongs_to :publisher, type: :uuid, index: true, unique: true, null: false
      t.references :publisher_note, type: :uuid
      t.boolean :enabled, null: false
      t.timestamps index: true
    end
  end
end
