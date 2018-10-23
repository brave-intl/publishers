class PromoCampaign < ApplicationRecord
  has_many :promo_registrations
  validates :name, uniqueness: true
end