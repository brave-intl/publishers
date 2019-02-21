module Partners
    class ReferralsController < ApplicationController
    include PromosHelper

    def index 
        respond_to do |format|
          format.html
          format.json  do 
            render json: aggregate_organization_data
          end 
        end
    end

    private
    def aggregate_organization_data
        membership = Membership.find_by(user_id: current_publisher.id)
        organization = Organization.find(membership.organization_id)
        partner_ids = Membership.where(organization_id: organization.id).map { |membership| membership.user_id}
        campaigns = []
        partner_ids.each do |partner_id|
          partner = Publisher.find(partner_id)
          partner.promo_campaigns.each do |promo_campaign|
            campaigns.push(promo_campaign.build_campaign_json)
          end
        end
        data = { campaigns: campaigns}
        return data
    end
    end
end