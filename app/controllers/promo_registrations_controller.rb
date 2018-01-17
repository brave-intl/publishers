class PromoRegistrationsController < ApplicationController
  before_action :authenticate_publisher!
  before_action :require_active_promo, only: %i(create)

  def index
    @publisher = current_publisher
    promo_running = active_promo_id.present?
    @publisher_promo_status = @publisher.promo_status(promo_running)
    render(:index)
  end

  def create
    @publisher = current_publisher
    @publisher.promo_enabled_2018q1 = true
    @publisher.save!

    # TO DO: register channel with promo service
    # TO DO: create new referral promo from response

  end

  private

  def active_promo_id
    Rails.application.secrets[:active_promo_id]
  end

  def publisher_activated_promo
    current_publisher.promo_enabled_2018q1
  end

  def require_active_promo
    return if active_promo_id.present?
    redirect_to index
  end
end
