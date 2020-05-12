class CacheUpholdTips < ApplicationJob
  queue_as :scheduler

  def perform(uphold_connection_for_channel_id:)
    upfc = UpholdConnectionForChannel.find(uphold_connection_for_channel_id)

    # Let's prematurely stop the pagination if we've already cached the most recent ids
    previously_cached_ids = upfc.cached_uphold_tips.order(uphold_created_at: :desc).limit(5).pluck(:uphold_transaction_id)

    # This can take a few minutes based on how many tips a publisher has.
    transactions = upfc.uphold_connection.uphold_client.transaction.all(
      id: upfc.card_id,
      previously_cached: previously_cached_ids
    )

    return if transactions.blank?

    transactions.each do |transaction|
       # Filter out transactions that weren't made by Brave Browser
      next unless transaction.anonymous_origin?

      cached_tip = CachedUpholdTip.find_or_initialize_by(uphold_transaction_id: transaction.id)
      cached_tip.update(
        uphold_connection_for_channel: upfc,
        amount: transaction.origin.dig("amount"),
        settlement_currency: transaction.destination.dig("currency"),
        settlement_amount: transaction.destination.dig("amount"),
        uphold_created_at: transaction.createdAt.to_date,
      )
    end
  end
end
