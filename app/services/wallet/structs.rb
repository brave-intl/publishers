# typed: true

module Wallet::Structs
  class FailedWithNotification
    attr_reader :result
  end

  class FailedWithoutNotification
    attr_reader :result
  end
end
