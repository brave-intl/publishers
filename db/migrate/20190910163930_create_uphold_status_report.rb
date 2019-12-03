class CreateUpholdStatusReport < ActiveRecord::Migration[5.2]
  def change
    add_column :uphold_connections, :member_at, :datetime

    create_table :uphold_status_reports, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.belongs_to :publisher, index: true, type: :uuid
      t.uuid :uphold_id, index: true
      t.timestamps
    end

    add_index :uphold_status_reports, :created_at
  end
end
