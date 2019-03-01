module Docker
  class EyeshadeHelper
    class << self
      def insert_contribution_transaction_sql(channel_identifier, amount, transaction_id)
        "insert into transactions (id, transaction_type, description, from_account_type, from_account, to_account_type, to_account, amount, channel) values('#{transaction_id}', 'contribution', 'manual insertion', 'uphold', '00000000-0000-4000-0000-000000000000 ', 'channel', '#{channel_identifier}', '#{amount}', '#{channel_identifier}');"
      end

      def insert_referral_transaction_sql(owner_identifier, amount, transaction_id)
        "insert into transactions (id, transaction_type, description, from_account_type, from_account, to_account_type, to_account, amount, channel) values('#{transaction_id}', 'referral', 'manual insertion', 'uphold', '00000000-0000-4000-0000-000000000000 ', 'owner', '#{owner_identifier}', '#{amount}', '#{owner_identifier}');"
      end

      def refresh_account_balances_sql
        "refresh materialized view account_balances;"
      end
    end
  end
end
