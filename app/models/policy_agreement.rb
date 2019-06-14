class PolicyAgreement < ActiveRecord::Base
  belongs_to :publisher

  validates_uniqueness_of :publisher_id
  validates_presence_of :publisher_id, :accepted_publisher_tos, :accepted_publisher_privacy_policy
end
