class CreateUpholdConnections < ActiveRecord::Migration[5.2]
  def change
    create_table :uphold_connections, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.string "uphold_state_token"
      t.boolean "uphold_verified", default: false
      t.string "encrypted_uphold_code"
      t.string "encrypted_uphold_code_iv"
      t.string "encrypted_uphold_access_parameters"
      t.string "encrypted_uphold_access_parameters_iv"

      t.timestamps
    end

    add_reference :publishers, :uphold_connections, index: true, foreign_key: { to_table: :uphold_connections }, type: :uuid
  end
end
