class CreateLoginActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :login_activities, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.references :publisher, type: :uuid
      t.text :user_agent
      t.text :accept_language
      t.timestamps
      t.index ["created_at"]
    end
  end
end
