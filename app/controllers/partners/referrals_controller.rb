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
        membership = Membership.find_by(user_id: current_publisher.id)
        organization = Organization.find(membership.organization_id)
        partner_ids = Membership.where(organization_id: organization.id).map { |membership| membership.user_id}
        data = {}
        campaigns = []
        partner_ids.each do |partner_id|
          partner = Publisher.find(partner_id)
          partner.promo_campaigns.each do |promo_campaign|
            promo_registrations = partner.promo_registrations.where(promo_campaign_id: promo_campaign.id)
            campaigns.push(
            {
                "promo_campaign_id": promo_campaign.id,
                "name": promo_campaign.name,
                "created_at": promo_campaign.created_at,
                "promo_registrations": promo_registrations
            })
          end
        end
        data[:campaigns] = campaigns  
        return data
    end
    end
end