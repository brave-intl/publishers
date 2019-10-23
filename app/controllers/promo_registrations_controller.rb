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
    current_publisher.channels.left_joins(:promo_registration).where(promo_registrations: {id: nil}).find_each do |channel|
      channel.register_channel_for_promo # Callee does a check
    end
    @promo_enabled_channels = @publisher.channels.joins(:promo_registration)
    @publisher_has_verified_channel = @publisher.has_verified_channel?
  end

  private

  def require_promo_running
    unless promo_running?
      redirect_to promo_registrations_path, action: "index"
    end
  end

  def require_publisher_promo_disabled
    if current_publisher.promo_enabled_2018q1
      redirect_to promo_registrations_path, action: "index"
    end
  end
end
