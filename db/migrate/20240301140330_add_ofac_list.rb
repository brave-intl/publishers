class AddOfacList < ActiveRecord::Migration[7.1]
  def change
    create_table :ofac_addresses, id: false do |t|
      t.string :address, null: false
    end
  end
end
