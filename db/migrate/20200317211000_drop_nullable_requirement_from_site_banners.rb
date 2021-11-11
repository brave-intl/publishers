# typed: ignore
class DropNullableRequirementFromSiteBanners < ActiveRecord::Migration[6.0]
  def change
    change_column_null :site_banners, :donation_amounts, true
    change_column_null :site_banners, :default_donation, true
  end
end
