class ChannelTransferController < ApplicationController
  include ChannelsHelper

  before_action :verify_token

  attr_reader :current_channel

  def reject_transfer
    Channels::RejectChannelTransfer.new(channel: current_channel).perform
    redirect_to home_publishers_path, notice: t("shared.channel_transfer_rejected")
  end

  private

  def verify_token
    @current_channel = Channel.find(params[:id])
    if @current_channel.nil? || @current_channel.contest_token.empty? || @current_channel.contest_token != params[:token_id]
      respond_to do |format|
        format.json {
          head 404
        }
        format.html {
          redirect_to home_publishers_path, notice: t("shared.channel_not_found")
        }
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.json {
        head 404
      }
      format.html {
        redirect_to home_publishers_path, notice: t("shared.channel_not_found")
      }
    end
  end
end
