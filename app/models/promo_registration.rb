class PromoRegistration < ApplicationRecord
  has_paper_trail
  
  belongs_to :channel, validate: true, autosave: true

  validates :channel_id, presence: true

  validates :promo_id, presence: true

  validates :referral_code, presence: true, uniqueness: { scope: :promo_id }
end
