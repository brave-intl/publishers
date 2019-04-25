class CreateUpholdConnections < ActiveRecord::Migration[5.2]
  def change
    create_table :uphold_connections, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.string :uphold_state_token
      t.boolean :uphold_verified, default: false
      t.boolean :is_member, default: false

      t.uuid :uphold_id
      t.uuid :address
      t.belongs_to :publisher, index: { unique: true }, type: :uuid

      t.string :encrypted_uphold_code
      t.string :encrypted_uphold_code_iv
      t.string :encrypted_uphold_access_parameters
      t.string :encrypted_uphold_access_parameters_iv

      t.timestamps
    end

    add_reference :publishers, :uphold_connection, index: true, foreign_key: { to_table: :uphold_connections }, type: :uuid
  end
end
