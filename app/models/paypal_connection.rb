class PaypalConnection < ActiveRecord::Base
  attr_encrypted :refresh_token, key: :encryption_key

  belongs_to :user, class_name: "Publisher", foreign_key: :user_id
end
