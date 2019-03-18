class PromoCampaign < ApplicationRecord
  has_many :promo_registrations
  validates :name, :uniqueness => { :case_sensitive => false }

  def build_campaign_json
    promo_registrations = PromoRegistration.where(promo_campaign_id: id)
    {
      promo_campaign_id: id,
      name: name,
      created_at: created_at,
      promo_registrations: promo_registrations,
    }
  end
end
