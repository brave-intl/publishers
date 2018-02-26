class ChannelsController < ApplicationController
  include ChannelsHelper

  before_action :authenticate_publisher!
  before_action :setup_current_channel,
                except: %i(cancel_add)
  attr_reader :current_channel

  def destroy
    channel_identifier = current_channel.details.channel_identifier
    update_promo_server = current_channel.promo_registration.present?

    if update_promo_server
      referral_code = current_channel.promo_registration.referral_code
    else
      referral_code = nil
    end

    channel_verified = current_channel.verified?

    success = current_channel.destroy
    if success && channel_verified
      DeletePublisherChannelJob.perform_later(publisher_id: current_publisher.id, 
                                              channel_identifier: channel_identifier, 
                                              update_promo_server: update_promo_server,
                                              referral_code: referral_code)
    end

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

  private

  def setup_current_channel
    @current_channel = current_publisher.channels.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    redirect_to home_publishers_path, notice: t("shared.channel_not_found")
  end
end