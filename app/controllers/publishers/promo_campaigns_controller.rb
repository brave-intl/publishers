class Publishers::PromoCampaignsController < ApplicationController
  before_action :authenticate_publisher!
  def index
    data = current_publisher.promo_campaigns
    render(status: 200, json: data)
  end

  def show
    data = current_publisher.promo_campaigns.find(params[:promo_campaign_id])
    render(status: 200, json: data) and return

    rescue ActiveRecord::RecordNotFound
      error_response = {
        errors: [{
          status: "404",
          title: "Not Found",
          detail: "Promo Campaign with id #{params[:id]} not found"
          }]
        }
    render(status: 404, json: error_response) and return
  end

  def create
    promo_campaign = PromoCampaign.create(
        name: params[:name],
        publisher_id: current_publisher.id
    )
    render(status: 200, json: promo_campaign)
  end
end
