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
        promo_campaign = current_publisher.promo_campaigns.find(sanitize(params[:id]))
        promo_campaign.update(name: sanitize(params[:name]))
    end

    def destroy
        data = JSON.parse(sanitize(params[:codes]))
        data.each do |code|
            promo_registration = current_publisher.promo_registrations.find(code)
            promo_registration.destroy
        end
        campaign = current_publisher.promo_campaigns.find(sanitize(params[:id]))
        campaign.destroy
    end
    end
end