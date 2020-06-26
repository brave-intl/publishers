class CachedUpholdTip < ApplicationRecord
  belongs_to :uphold_connection_for_channel

  def publication_title
    uphold_connection_for_channel.channel.details.publication_title
  end

  def to_statement
    PublisherStatementGetter::Statement.new(
      channel: publication_title,
      transaction_type: PublisherStatementGetter::Statement::UPHOLD_CONTRIBUTION,
      amount: amount&.to_d,
      settlement_currency: settlement_currency,
      settlement_amount: settlement_amount&.to_d,
      settlement_destination: uphold_connection_for_channel.card_id,
      created_at: uphold_created_at,
    )
  end
end
