class AddCreatedByToPublisherNotes < ActiveRecord::Migration[5.0]
  change_table :publisher_notes do |t|
    t.references :created_by, type: :uuid, index: true, null: false, foreign_key: { to_table: :publishers }
  end
end