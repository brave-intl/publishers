class CreateRequestGraphs < ActiveRecord::Migration[6.1]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  def change
    create_table :request_graphs, id: :uuid do |t|
      t.string :ip_address, null: false, index: { unique: true }
      t.integer :count, null: false, default: 0
      t.timestamps
    end
  end
end
