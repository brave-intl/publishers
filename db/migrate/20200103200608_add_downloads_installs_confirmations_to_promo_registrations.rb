# typed: ignore
class AddDownloadsInstallsConfirmationsToPromoRegistrations < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_registrations, :aggregate_downloads, :int, default: 0, null: false, index: true
    add_column :promo_registrations, :aggregate_installs, :int, default: 0, null: false, index: true
    add_column :promo_registrations, :aggregate_confirmations, :int, default: 0, null: false, index: true
  end
end
