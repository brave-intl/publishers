class Membership < ActiveRecord::Base
  belongs_to :organization, class_name: "Organization"

  # Publisher model will be responsible for casting to the right sub-role
  # E.g. casting from Publisher to Partner
  belongs_to :member, class_name: "Publisher", foreign_key: :user_id

  validates_presence_of :organization_id
  validates_presence_of :user_id
end
