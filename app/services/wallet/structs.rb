# typed: true

module Wallet::Structs
  FailedWithNotification = Struct.new(:result)
  FailedWithoutNotification = Struct.new(:result)
end
