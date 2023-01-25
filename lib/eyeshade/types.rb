# typed: true

module Eyeshade
  module Types
    ### Derived Types

    ConvertedBalance = Struct.new(
      :amount_bat,
      :fees_bat,
      :amount_default_currency,
      :amount_usd,
      keyword_init: true
    )

    ### API Response Types

    # See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L304-L312
    AccountBalance = Struct.new(
      :account_type,
      :account_id,
      :balance,
      keyword_init: true
    )

    # See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L159-L176
    # FIXME: I'm trying to keep nomenclature as close as possible to the eyeshade API and specifically the associated
    # endpoints.  This should technically be an "AccountTransaction" as it is '/accounts/transactions'
    #
    # Ideally we would do this dynamically or at least enforce nomenclature but that is a nice to have.
    Transaction = Struct.new(
      :created_at,
      :description,
      :channel,
      :amount,
      :transaction_type,
      # FIXME: I don't know if these are actually nilable but the example response data I have
      # was either missing/incorrect or both.
      :settlement_currency,
      :settlement_amount,
      :settlement_destination_type,
      :settlement_destination,
      :to_account,
      :from_account,
      keyword_init: true
    )

    # See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L340-L399
    #
    # There is going to be redundancy here in terms of type definitions, because all earnings totals have the same schema, but are only differentiated by the "<type>" parameter of the endpoint. (See: https://github.com/brave-intl/bat-ledger/blob/dfa58715e1e14278a7dde545c7dd3fe68621deff/eyeshade/controllers/accounts.js#L340)
    #
    # This however will be a good thing because we will know empirically that a record value is of type "Referral Earning Total" versus any other type because we have created explicit immutable type containers for each response i.e.
    #
    #
    # Please use the format for any subsequent total response objects
    #    <Type>EarningTotal = Struct.new(
    #      prop :channel, String
    #      prop :earnings, String
    #      prop :account_id, String
    #    end
    #
    ReferralEarningTotal = Struct.new(
      :channel,
      :earnings,
      :account_id,
      keyword_init: true
    )

    # All eyeshade values are strings
    class EyeshadeObject; end

    class EyeshadeArray; end

    class Transactions; end

    class AccountBalances; end

    class ConvertedBalances; end

    class ReferralEarningTotals; end
  end
end
