class RenameOfacAddressesToProhibitedList < ActiveRecord::Migration[8.1]
  def change
    # Small, admin-managed list; code referencing the new name ships in the same deploy.
    safety_assured do
      rename_table :ofac_addresses, :prohibited_list
      reversible do |dir|
        dir.up do
          execute "UPDATE service_runs SET service_name = 'ParseProhibitedListService' WHERE service_name = 'ParseOfacListService'"
        end
        dir.down do
          execute "UPDATE service_runs SET service_name = 'ParseOfacListService' WHERE service_name = 'ParseProhibitedListService'"
        end
      end
    end
  end
end
