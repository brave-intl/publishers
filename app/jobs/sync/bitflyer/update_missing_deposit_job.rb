class Sync::Bitflyer::UpdateMissingDepositJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: true

  def initialize(channel_id)
    @channel = Channel.find(channel_id)
  end

  def perform
    return if @channel.deposit_id.present?
    # Request a deposit id from bitFlyer.
    url = URI.parse(Rails.application.secrets[:bitflyer_host] + '/api/link/v1/account/create-deposit-id?request_id=' + SecureRandom.uuid)
    request = Net::HTTP::Get.new(url.to_s)
    request['Authorization'] = "Bearer " + @channel.publisher.bitflyer_connection.access_token
    response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
      http.request(request)
    end

    deposit_id = JSON.parse(response.body)["deposit_id"]
    @channel.update(deposit_id: deposit_id)
  end
end
