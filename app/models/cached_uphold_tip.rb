class CachedUpholdTip < ApplicationRecord
  belongs_to :uphold_connection_for_channel

  def channel
    uphold_connection_for_channel.channel.details.publication_title
  end

  def to_statement
    PublisherStatementGetter::Statement.new(
      channel: channel,
      transaction_type: PublisherStatementGetter::Statement::UPHOLD_CONTRIBUTION,
      amount: amount&.to_d,
      settlement_currency: settlement_currency,
      settlement_amount: settlement_amount&.to_d,
      created_at: uphold_created_at,
    )
  end
end
