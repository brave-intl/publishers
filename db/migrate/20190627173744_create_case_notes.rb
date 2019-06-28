class CreateCaseNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :case_notes, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.belongs_to :case, type: :uuid, index: true, null: false

      t.belongs_to :created_by, index: true, type: :uuid

      t.string :type
      t.text :note
      t.timestamps
    end
  end
end
