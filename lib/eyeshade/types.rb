# typed: true

module Eyeshade
  module Types
    extend T::Sig

    ### Derived Types

    class ConvertedBalance < T::Struct
      const :amount_bat, BigDecimal
      const :fees_bat, BigDecimal
      const :amount_default_currency, BigDecimal
      const :amount_usd, BigDecimal
    end

    ### API Response Types

    # See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L304-L312
    class AccountBalance < T::Struct
      const :account_type, String
      const :account_id, String
      const :balance, String
    end

    # See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L159-L176
    # FIXME: I'm trying to keep nomenclature as close as possible to the eyeshade API and specifically the associated
    # endpoints.  This should technically be an "AccountTransaction" as it is '/accounts/transactions'
    #
    # Ideally we would do this dynamically or at least enforce nomenclature but that is a nice to have.
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

    # See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L340-L399
    #
    # There is going to be redundancy here in terms of type definitions, because all earnings totals have the same schema, but are only differentiated by the "<type>" parameter of the endpoint. (See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L340)
    #
    # This however will be a good thing because we will know empirically that a record value is of type "Referral Earning Total" versus any other type because we have created explicit immutable type containers for each response i.e.
    #
    #
    # Please use the format for any subsequent total response objects
#    class <Type>EarningTotal
#      prop :channel, String
#      prop :earnings, String
#      prop :account_id, String
#    end
#
    class ReferralEarningTotal < T::Struct
      prop :channel, String
      prop :earnings, String
      prop :account_id, String
    end

    # All eyeshade values are strings
    EyeshadeObject = T.type_alias { T::Hash[String, String] }
    EyeshadeArray = T.type_alias { T::Array[EyeshadeObject] }
    Transactions = T.type_alias { T::Array[Transaction] }
    AccountBalances = T.type_alias { T::Array[AccountBalance] }
    ConvertedBalances = T.type_alias { T::Array[ConvertedBalance] }
    ReferralEarningTotals = T.type_alias { T::Array[ReferralEarningTotal] }
  end
end
