# typed: true

module Eyeshade
  module Types
    extend T::Sig

    class Balance < T::Struct
      const :amount_bat, BigDecimal
      const :fees_bat, BigDecimal
      const :amount_default_currency, BigDecimal
      const :amount_usd, BigDecimal
    end

    class Account < T::Struct
      const :account_type, String
      const :account_id, String
      const :balance, String
    end

    # All eyeshade values are strings
    EyeshadeObject = T.type_alias { T::Hash[String, String] }
    EyeshadeArray = T.type_alias { T::Array[EyeshadeObject] }
  end
end
