class UploadUpholdAccessParametersJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)

    if publisher.uphold_connection.uphold_access_parameters.blank?
      Rails.logger.info("Publisher #{publisher.id} is missing uphold_access_parameters. UpholdConnection #{publisher.uphold_connection.to_json}")
      SlackMessenger.new(message: "🤔 Publisher #{publisher.id} is missing uphold_access_parameters.").perform
      return
    end

    PublisherWalletSetter.new(publisher: publisher).perform

    publisher.uphold_connection.verify_uphold
  end
end
