class CreatePublisherStatusUpdates < ActiveRecord::Migration[5.0]
  def change
    create_table :publisher_status_updates, id: :uuid do |t|
      t.references :publisher, type: :uuid, index: true, null: false
      t.string :status, null: false
      t.datetime :created_at, null: false
    end
  end
end
