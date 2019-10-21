class PaypalConnection < ActiveRecord::Base
  attr_encrypted :refresh_token, key: :encryption_key
end
