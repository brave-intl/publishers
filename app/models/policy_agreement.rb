class PolicyAgreement < ActiveRecord::Base
  belongs_to :publisher, class_name: "Publisher", foreign_key: :user_id

  validates_uniqueness_of :user_id
  validates_presence_of :user_id, :accepted_publisher_tos, :accepted_publisher_privacy_policy
end
