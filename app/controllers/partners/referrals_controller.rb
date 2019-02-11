module Partners
    class ReferralsController < ApplicationController
    include PromosHelper

    def index 
        respond_to do |format|
          format.html
          format.json  do 
            render json: prepare_json
          end 
        end
    end

    private
    def prepare_json
        data = {}
        unassigned_codes = current_publisher.promo_registrations.where(promo_campaign_id: nil)
        campaigns = []
    
        current_publisher.promo_campaigns.each do |promo_campaign|
        promo_registrations = current_publisher.promo_registrations.where(promo_campaign_id: promo_campaign.id)
        campaigns.push(
        {
            "promo_campaign_id": promo_campaign.id,
            "name": promo_campaign.name,
            "created_at": promo_campaign.created_at,
            "promo_registrations": promo_registrations
        }
        )
        end
    
        data[:unassigned_codes] = unassigned_codes
        data[:campaigns] = campaigns  
        return data
    end
    end
end