class Api::Nextv1::ChannelsController < Api::Nextv1::BaseController
  include ChannelsHelper

  before_action :authenticate_publisher!

  before_action :setup_current_channel

  attr_reader :current_channel

  def destroy
    success = DeletePublisherChannelJob.perform_now(current_channel.id)

    if success
      head :no_content
    else
      render(json: {errors: current_channel.errors}, status: 400)
    end
  end

  private

  def setup_current_channel
    @current_channel = current_publisher.channels.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render(json: {}, status: 404)
  end
end