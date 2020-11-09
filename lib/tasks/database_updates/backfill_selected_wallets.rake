namespace :database_updates do
  task :backfill_selected_wallets => :environment do
    uphold_connected_publishers = UpholdConnection.all
    paypal_connected_publishers = PaypalConnection.all
    gemini_connected_publishers = GeminiConnection.all

    publishers_without_selected_wallet = Publisher.where(selected_wallet_provider_id: nil)

    publishers_without_selected_wallet.each do |publisher|
      gemini_connection = gemini_connected_publishers.where(publisher_id: publisher.id)
      if gemini_connection.present?
        publisher.update!(selected_wallet_provider_type: 'GeminiConnection', selected_wallet_provider_id: gemini_connection.id)
        next
      end

      paypal_connection = paypal_connected_publishers.where(user_id: publisher.id)
      if paypal_connection.present?
        publisher.update!(selected_wallet_provider_type: 'PaypalConnection', selected_wallet_provider_id: paypal_connection.id)
        next
      end

      uphold_connection = uphold_connected_publishers.where(publisher_id: publisher.id)
      if uphold_connection.present?
        publisher.update!(selected_wallet_provider_type: 'UpholdConnection', selected_wallet_provider_id: uphold_connection.id)
        next
      end
    end
  end
end

