class Organization < ActiveRecord::Base
  has_many :memberships

  validates_presence_of :name
end
