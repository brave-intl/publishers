class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.uuid :partner_id
      t.uuid :uploaded_by
      t.bigint :amount_bat

      t.index :partner_id
    end
  end
end
