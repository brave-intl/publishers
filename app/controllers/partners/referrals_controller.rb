module Partners
  class ReferralsController < ApplicationController
    include PromosHelper

    def index
      respond_to do |format|
        format.html
        format.json do
          render json: aggregate_organization_data
        end
      end
    end
    
    private

    def aggregate_organization_data
      campaigns = []
      current_publisher.promo_campaigns.each do |promo_campaign|
        campaigns.push(promo_campaign.build_campaign_json)
      end
      { campaigns: campaigns }
    end
  end
end
