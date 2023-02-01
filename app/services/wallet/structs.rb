# typed: true

module Wallet::Structs
  FailedWithNotification = Struct.new(:result, keyword_init: true)
  FailedWithoutNotification = Struct.new(:result, keyword_init: true)
end
