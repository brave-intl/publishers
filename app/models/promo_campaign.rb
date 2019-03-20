class PromoCampaign < ApplicationRecord
  has_many :promo_registrations
  validates :name, :uniqueness => {:case_sensitive => false}
  belongs_to :partner, foreign_key: :publisher_id

  def build_campaign_json
    promo_registrations = PromoRegistration.where(promo_campaign_id: self.id)
    {
      promo_campaign_id: self.id,
      name: self.name,
      created_at: self.created_at,
      promo_registrations: promo_registrations
    }
  end
end
