class PromoRegistrationsController < ApplicationController
  include PromosHelper
  before_action :authenticate_publisher!
  before_action :require_publisher_promo_disabled, only: %(create)
  before_action :require_promo_running, only: %i(create)

  def index
    @publisher = current_publisher
    @publisher_promo_status = @publisher.promo_status(promo_running?)
    @promo_enabled_channels = @publisher.channels.joins(:promo_registration)
  end

  def create
    @publisher = current_publisher
    @publisher.promo_enabled_2018q1 = true
    @publisher.save!
    @publisher_has_verified_channel = @publisher.has_verified_channel?

    if @publisher_has_verified_channel
      if @publisher.channels.where(verified: true).count > 5
        Promo::RegisterPublisherForPromoJob.perform_later(publisher: @publisher)
        redirect_to home_publishers_path, notice: t("promo.activated.please_wait")
      else
        Promo::PublisherChannelsRegistrar.new(publisher: @publisher).perform
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
    if current_publisher.promo_enabled_2018q1
      render(:index)
    end
  end
end
