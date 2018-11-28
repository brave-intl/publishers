class Organization < ActiveRecord::Base
  has_many :memberships
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
