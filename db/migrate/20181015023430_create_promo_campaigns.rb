class CreatePromoCampaigns < ActiveRecord::Migration[5.2]
  def change
    create_table :promo_campaigns, id: :uuid,default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string :name
      t.timestamps
    end
    add_index :promo_campaigns, :name, unique: true
  end
end
