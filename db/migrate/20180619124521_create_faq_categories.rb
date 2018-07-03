class CreateFaqCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :faq_categories, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.string :name
      t.integer :rank

      t.timestamps
    end
    add_index :faq_categories, :name, unique: true
    add_index :faq_categories, :rank
  end
end
