class PromoRegistrationsController < ApplicationController
  include PromosHelper

  before_action :find_publisher
  before_action :require_publisher_promo_disabled, only: %(create)
  before_action :require_promo_running, only: %i(create)

  def index
    @publisher_promo_status = @publisher.promo_status(promo_running?)
    @promo_enabled_channels = @publisher.channels.joins(:promo_registration)
    render(:index)
  end

  def create
    @publisher.promo_enabled_2018q1 = true
    @publisher.save!
    @publisher_has_verified_channel = @publisher.has_verified_channel?

    if @publisher_has_verified_channel
      PromoRegistrar.new(publisher: @publisher).perform
      @promo_enabled_channels = @publisher.channels.joins(:promo_registration)
    end
  end

  private

  def require_promo_running
    return if promo_running?
    redirect_to index
  end

  def require_publisher_promo_disabled
    return unless @publisher.promo_enabled_2018q1
    redirect_to index
  end
  
  # Fails when a pub is logged in and clicks "activate promo" button
  # from email sent to their other publisher account
  def find_publisher
    if current_publisher
      @publisher = current_publisher
    else
      begin
        # Get promo auth token from params if they exist
        promo_token = params.require(:promo_token)
      rescue => e
        require "sentry-raven"
        Raven.capture_exception(e)
        return redirect_to(root_path, alert: I18n.t("promo.publisher_not_found"))
      end

      if publisher = Publisher.find_by(promo_token_2018q1: promo_token)
        @publisher = publisher
      else
        redirect_to(root_path, alert: I18n.t("promo.publisher_not_found"))
      end
    end
  end
end
