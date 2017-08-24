class AddUpholdAccessParametersToPublishers < ActiveRecord::Migration[5.0]
  def change
    change_table :publishers do |t|
      t.string :encrypted_uphold_code
      t.string :encrypted_uphold_code_iv
      t.string :encrypted_uphold_access_parameters
      t.string :encrypted_uphold_access_parameters_iv
    end
  end
end
