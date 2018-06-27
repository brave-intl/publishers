class CreateFaqs < ActiveRecord::Migration[5.0]
  def change
    create_table :faqs, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.string :question
      t.string :answer
      t.integer :rank
      t.references :faq_category, type: :uuid

      t.timestamps
    end
    add_index :faqs, :question, unique: true
    add_index :faqs, :rank
  end
end
