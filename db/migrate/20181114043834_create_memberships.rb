class CreateMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :memberships, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.references :organization, null: false, type: :uuid
      t.references :user, null: false, type: :uuid
      t.timestamps
    end

    create_table :organizations, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.text :name
      t.timestamps
    end
  end
end
