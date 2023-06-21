# typed: ignore

class Api::V3::Public::ChannelsController < Api::V3::Public::BaseController
  def total_verified
    total_verified_json = Channel.verified.count
    render(json: total_verified_json, status: 200)
  end
end
