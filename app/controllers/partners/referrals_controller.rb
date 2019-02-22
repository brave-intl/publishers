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
      partner_ids = Membership.find_by(user_id: current_publisher.id).organization.
                    memberships.map { |membership| membership.user_id}
      partner_ids.each do |partner_id|
        partner = Publisher.find(partner_id)
        partner.promo_campaigns.each do |promo_campaign|
          campaigns.push(promo_campaign.build_campaign_json)
        end
      end
      data = { campaigns: campaigns }
      data
    end
  end
end
