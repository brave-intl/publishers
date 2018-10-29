class PromoCampaign < ApplicationRecord
  has_many :promo_registrations
  validates :name, :uniqueness => {:case_sensitive => false}
end