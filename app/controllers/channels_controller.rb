class ChannelsController < ApplicationController
  include ChannelsHelper

  before_action :authenticate_publisher!

  before_action :setup_current_channel,
                except: %i(cancel_add)

  attr_reader :current_channel

  def destroy
    success = DeletePublisherChannelJob.perform_now(channel_id: current_channel.id)

    respond_to do |format|
      format.json {
        if success
          head :no_content
        else
          render(json: { errors: current_channel.errors }, status: 400)
        end
      }
    end
  end

  def cancel_add
    channel = current_publisher.channels.find(params[:id])
    if channel && !channel.verified?
      channel.destroy
    end
    redirect_to(home_publishers_path)
  end

  def verification_status
    respond_to do |format|
      format.json {
        render(json: { status: channel_verification_status(current_channel),
                       details: failed_verification_details(current_channel).nil? ? nil : failed_verification_details(current_channel).upcase_first },
               status: 200)
      }
    end
  end

  private

  def setup_current_channel
    @current_channel = current_publisher.channels.find(params[:id])
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
