# typed: true

module Wallet::Structs
  class FailedWithNotification < T::Struct
    prop :result, Oauth2::Responses::ErrorResponse
  end

  class FailedWithoutNotification < T::Struct
    prop :result, Oauth2::Responses::ErrorResponse
  end
end
