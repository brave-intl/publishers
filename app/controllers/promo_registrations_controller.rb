class PromoRegistrationsController < ApplicationController
  include PromosHelper

  before_action :find_publisher
  before_action :require_publisher_promo_disabled, only: %(create)
  before_action :require_promo_running, only: %i(create)

  def index
  end

  def create
    @publisher.promo_enabled_2018q1 = true
    @publisher.save!
    @publisher_has_verified_channel = @publisher.has_verified_channel?

    if @publisher_has_verified_channel
      if @publisher.channels.where(verified: true).count > 5
        RegisterPublisherForPromoJob.perform_later(publisher: @publisher)
        redirect_to home_publishers_path, notice: t("promo.activated.please_wait")
      else
        PromoRegistrar.new(publisher: @publisher).perform
        @promo_enabled_channels = @publisher.channels.joins(:promo_registration)
        PromoMailer.promo_activated_2018q1_verified(@publisher, @promo_enabled_channels).deliver
      end
    else
      PromoMailer.promo_activated_2018q1_unverified(@publisher).deliver
    end
  end

  private

  def require_promo_running
    unless promo_running?
      render(:index)
    end
  end

  def require_publisher_promo_disabled
    if @publisher.promo_enabled_2018q1
      render(:index)
    end
  end
  
  def find_publisher
    if current_publisher
      @publisher = current_publisher
    else
      if params[:promo_token].present?
        promo_token = params[:promo_token]
      elsif params[:publisher][:promo_token].present?
        promo_token = params[:publisher][:promo_token]
      else
        return redirect_to(root_path, alert: I18n.t("promo.publisher_not_found"))
      end
      if publisher = Publisher.find_by(promo_token_2018q1: promo_token)
        @publisher = publisher
      else
        return redirect_to(root_path, alert: I18n.t("promo.publisher_not_found"))
      end
    end

    @publisher_promo_status = @publisher.promo_status(promo_running?)
    @promo_enabled_channels = @publisher.channels.joins(:promo_registration)
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    return redirect_to(root_path, alert: I18n.t("promo.publisher_not_found"))
  end
end
