class ChannelsController < ApplicationController
  include ChannelsHelper

  before_action :authenticate_publisher!
  before_action :setup_current_channel
  attr_reader :current_channel

  def update
    current_channel.update(channel_update_params)
  end

  def destroy
    current_channel.destroy
    redirect_to(home_publishers_path, alert: t("channel.channel_removed"))
  end

  private

  def channel_update_params
    params.require(:channel).permit(:show_verification_status)
  end

  def setup_current_channel
    @current_channel = current_publisher.channels.find(params[:id])
    return if @current_channel
    redirect_to(home_publishers_path)
  rescue ActiveRecord::RecordNotFound => e
    redirect_to(home_publishers_path, alert: t("channel.channel_not_found"))
  end
end