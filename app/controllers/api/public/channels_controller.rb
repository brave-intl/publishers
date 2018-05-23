class Api::Public::ChannelsController < Api::BaseController
  def identity
    builder = JsonBuilders::IdentityJsonBuilder.new(publisher_name: params[:publisher]).build

    if builder.errors.present?
      render(status: 404,
        json: {
          errors: builder.errors.to_s
        })
    else
      render(status: 200, json: builder.result)
    end
  end

  def timestamp
    latest_updated_at = Rails.cache.fetch("last_updated_channel_timestamp", expires_in: 10.seconds) do
      Channel.maximum("updated_at").to_i << 32
    end
    render status: 200, json: { timestamp: latest_updated_at }
  end
end
