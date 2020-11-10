namespace :database_updates do
  task :backfill_selected_wallets => :environment do
    publishers_without_selected_wallet = Publisher.where(selected_wallet_provider_id: nil)

    paypal_connections = PaypalConnection.where(user_id: publishers_without_selected_wallet.pluck(:id))
    gemini_connections = GeminiConnection.where(publisher_id: publishers_without_selected_wallet.pluck(:id))
    uphold_connections = UpholdConnection.where(publisher_id: publishers_without_selected_wallet.pluck(:id))

    publishers_without_selected_wallet.find_each do |publisher|
      gemini_connection = gemini_connections.where(publisher_id: publisher.id)
      if gemini_connection.present?
        publisher.update!(selected_wallet_provider_type: "GeminiConnection", selected_wallet_provider_id: gemini_connection.id)
        Rails.logger.info("Assigned publisher #{publisher.id} GeminiConnection #{gemini_connection.id}")
        next
      end

      paypal_connection = paypal_connections.where(user_id: publisher.id)
      if paypal_connection.present?
        publisher.update!(selected_wallet_provider_type: "PaypalConnection", selected_wallet_provider_id: paypal_connection.id)
        Rails.logger.info("Assigned publisher #{publisher.id} PaypalConnection #{paypal_connection.id}")
        next
      end

      uphold_connection = uphold_connections.where(publisher_id: publisher.id)
      if uphold_connection.present?
        publisher.update!(selected_wallet_provider_type: "UpholdConnection", selected_wallet_provider_id: uphold_connection.id)
        Rails.logger.info("Assigned publisher #{publisher.id} UpholdConnection #{uphold_connection.id}")
        next
      end
    end
  end
end
