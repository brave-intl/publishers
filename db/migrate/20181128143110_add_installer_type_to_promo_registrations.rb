class AddInstallerTypeToPromoRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :promo_registrations, :installer_type, :string
  end
end
