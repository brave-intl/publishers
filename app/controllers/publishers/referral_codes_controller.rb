class Publishers::ReferralCodesController < ApplicationController
  include PromosHelper
  before_action :authenticate_publisher!

  def index
    if params[:promo_campaign_id].to_s == 'null'
      data = current_publisher.promo_registrations.where(promo_campaign_id: nil).to_json
    elsif params[:promo_campaign_id].present?
      data = current_publisher.promo_registrations.where(promo_campaign_id)
    end
    render(status: 200, json: data)
  end

  def show
    data = current_publisher.promo_registrations.where(id: params[:id]).to_json
    render(status: 200, json: data) and return

    rescue ActiveRecord::RecordNotFound
      error_response = {
        errors: [{
          status: "404",
          title: "Not Found",
          detail: "Promo Registration with id #{params[:id]} not found"
          }]
        }
    render(status: 404, json: error_response) and return
  end

  def create
    Promo::OwnerRegistrar.new(
      number: params[:number].to_i,
      publisher_id: current_publisher.id,
      promo_campaign_id: params[:promo_campaign_id]).perform
    Promo::RegistrationsStatsFetcher.new(promo_registrations: current_publisher.promo_registrations).perform
  end
end
