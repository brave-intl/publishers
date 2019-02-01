class Publishers::PromoCampaigns::PromoRegistrationsController < ApplicationController
  before_action :authenticate_publisher!

  def index
    data = current_publisher.promo_campaigns.find(params[:promo_campaign_id]).promo_registrations
    render(status: 200, json: data.to_json) and return
  end
end
