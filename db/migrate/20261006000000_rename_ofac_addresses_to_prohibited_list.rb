class RenameOfacAddressesToProhibitedList < ActiveRecord::Migration[8.1]
  def change
    # Small, admin-managed list; code referencing the new name ships in the same deploy.
    safety_assured { rename_table :ofac_addresses, :prohibited_list }
  end
end
