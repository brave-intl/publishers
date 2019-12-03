class CreateCaseReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :case_replies, id: :uuid, default: -> { "uuid_generate_v4()"}, force: :cascade do |t|
      t.string :title
      t.text :body
      t.timestamps
    end
  end
end
