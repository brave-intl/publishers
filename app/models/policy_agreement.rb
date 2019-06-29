class PolicyAgreement < ActiveRecord::Base
  belongs_to :publisher, class_name: "Publisher", foreign_key: :user_id

  validates_uniqueness_of :user_id
  validates_presence_of :user_id
  attribute :accepted_publisher_tos, :boolean, default: false
  attribute :accepted_publisher_privacy_policy, :boolean, default: false

  def accepted?
    accepted_publisher_tos && accepted_publisher_privacy_policy
  end
end
