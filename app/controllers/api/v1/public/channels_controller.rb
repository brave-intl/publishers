class Api::V1::Public::ChannelsController < Api::V1::Public::BaseController
  include BrowserChannelsDynoCaching
  def totals
    render(json: Channel.statistical_totals, status: 200)
  end

  private

  def dyno_expiration_key
    "browser_v1_channels_expiration:#{ENV['DYNO']}"
  end

  def klass_dyno_cache
    @@api_v1_public_channels_cache
  end
end
