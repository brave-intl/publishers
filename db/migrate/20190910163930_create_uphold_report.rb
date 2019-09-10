class CreateUpholdReport < ActiveRecord::Migration[5.2]
  def change
    add_column :uphold_connections, :member_at, :datetime

    create_table :uphold_reports, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.belongs_to :publisher, index: true, type: :uuid
      t.uuid :uphold_id
      t.timestamps
    end

    add_index :uphold_reports, :created_at
  end
end
