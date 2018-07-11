class Api::Public::ChannelsController < Api::Public::BaseController
  def channels
    channels_json = JsonBuilders::ChannelsJsonBuilder.new.build
    render(json: channels_json, status: 200)
  end
end