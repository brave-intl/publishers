class CreatePublisherStatements < ActiveRecord::Migration[5.0]
  def change
    create_table :publisher_statements, id: :uuid do |t|
      t.references :publisher, type: :uuid, index: true, null: false
      t.string :period, null: :false
      t.string :source_url
      t.text :encrypted_contents
      t.string :encrypted_contents_iv
      t.timestamp :expires_at
      t.timestamps
    end
  end
end
