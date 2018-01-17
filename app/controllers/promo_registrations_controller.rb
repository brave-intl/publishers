class PromoRegistrationsController < ApplicationController
  before_action :authenticate_publisher!
  before_action :require_active_promo, only: %i(create)

  def index
    @publisher = current_publisher
    @publisher_promo_status = @publisher.promo_status(promo_running)
    render(:index)
  end

  def create
    @publisher = current_publisher
    @publisher.promo_enabled_2018q1 = true
    @publisher.save!

    PromoRegistrar.new(publisher: @publisher).perform
  end

  private

  def promo_running
    Rails.application.secrets[:active_promo_id].present?
  end

  def publisher_activated_promo
    current_publisher.promo_enabled_2018q1
  end

  def require_active_promo
    return if promo_running
    redirect_to index
  end
end
