include ActionView::Helpers::SanitizeHelper
module Partners
    class PromoCampaignsController < ApplicationController
    def create
        promo_campaign = PromoCampaign.create(
            name: sanitize(params[:name]),
            publisher_id: current_publisher.id
        )
        render(status: 200, json: promo_campaign)
    end

    def update
        promo_campaign = PromoCampaign.find(sanitize(params[:id]))
        promo_campaign.update(name: sanitize(params[:name]))
    end

    def destroy
        if params[:codes] 
            data = JSON.parse(sanitize(params[:codes]))
            data.each do |code|
                promo_registration = PromoRegistration.find(code)
                promo_registration.destroy
            end
        end
        campaign = PromoCampaign.find(sanitize(params[:id]))
        campaign.destroy
    end
    end
end