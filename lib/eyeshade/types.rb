# typed: true

module Eyeshade
  module Types
    extend T::Sig

    class ConvertedBalance < T::Struct
      const :amount_bat, BigDecimal
      const :fees_bat, BigDecimal
      const :amount_default_currency, BigDecimal
      const :amount_usd, BigDecimal
    end

    # See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L304-L312
    class AccountBalance < T::Struct
      const :account_type, String
      const :account_id, String
      const :balance, String
    end

    # See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L159-L176
    class Transaction < T::Struct
      const :created_at, String
      const :description, String
      const :channel, String
      const :amount, String
      const :transaction_type, String

      # FIXME: I don't know if these are actually nilable but the example response data I have
      # was either missing/incorrect or both.
      prop :settlement_currency, T.nilable(String)
      prop :settlement_amount, T.nilable(String)
      prop :settlement_destination_type, T.nilable(String)
      prop :settlement_destination, T.nilable(String)
      prop :to_account, T.nilable(String)
      prop :from_account, T.nilable(String)
    end

    # All eyeshade values are strings
    EyeshadeObject = T.type_alias { T::Hash[String, String] }
    EyeshadeArray = T.type_alias { T::Array[EyeshadeObject] }
    Transactions = T.type_alias { T::Array[Transaction] }
    AccountBalances = T.type_alias { T::Array[AccountBalance] }
    ConvertedBalances = T.type_alias { T::Array[ConvertedBalance] }
  end
end
