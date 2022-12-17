# typed: ignore

class PublisherPayoutFeedbackStatusUpdater < BuilderBaseService
  def self.build
    new
  end

  def call(to_update_list:)
    by_publisher = to_update_list.group_by { |i| i["owner"] }
    by_publisher.each do |publisher_str, channels|
      Rails.logger.info("Processing #{publisher_str} with channels: #{channels.map { |c| c["publisher"] }.join(";")}")
      publisher = Publisher.where(id: publisher_str.sub("publishers#uuid:", "")).first
      if publisher.blank?
        Rails.logger.info("Couldn't find publisher #{publisher_str}!")
        next
      end
      publisher_wp_id = publisher.selected_wallet_provider&.wallet_provider_id
      provided_wp_id = channels[0]["walletProviderId"]
      if publisher_wp_id == provided_wp_id && publisher_wp_id.present?
        Rails.logger.info("Setting bad wallet for #{publisher.id} with email #{publisher.email}")
        publisher.selected_wallet_provider&.record_refresh_failure!
      else
        Rails.logger.info("Wallet mismatch for publisher #{publisher.id}, perhaps they've already reconnected a new one")
        Rails.logger.info("Our record: #{publisher_wp_id}")
        Rails.logger.info("Provided: #{provided_wp_id}")
      end
    end
  end
end
