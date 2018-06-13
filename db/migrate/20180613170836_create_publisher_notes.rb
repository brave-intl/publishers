class CreatePublisherNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :publisher_notes, id: :uuid do |t|
      t.references :publisher, type: :uuid, index: true, null: false
      t.text :note
      t.timestamps
    end
  end
end