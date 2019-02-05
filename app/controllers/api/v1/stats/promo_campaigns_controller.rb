class Api::V1::Stats::PromoCampaignsController < Api::V1::StatsController
  def index
    data = []
    PromoCampaign.all.each do |promo_campaign|
      promo_registrations = []
      promo_campaign_promo_registrations = PromoRegistration.joins(:promo_campaign).
                                                             where(promo_campaigns: {id: promo_campaign.id})
      promo_campaign_promo_registrations.each do |promo_registration|
        promo_registrations.push(
          {
            "promo_registration_id": promo_registration.id,
            "referral_code": promo_registration.referral_code
          }
        )
      end

      data.push(
        {
          "promo_campaign_id": promo_campaign.id,
          "name": promo_campaign.name,
          "promo_registrations": promo_registrations
        }
      )
    end
    render(status: 200, json: data)
  end

  def show
    promo_campaign = PromoCampaign.find_by_id!(params[:id])
    promo_registrations = []
    promo_campaign_promo_registrations = PromoRegistration.joins(:promo_campaign).
                                                           where(promo_campaigns: {id: promo_campaign.id})
    promo_campaign_promo_registrations.each do |promo_registration|
      promo_registrations.push(
        {
          "promo_registration_id": promo_registration.id,
          "referral_code": promo_registration.referral_code
        }
      )
    end

    data = {
      "promo_campaign_id": promo_campaign.id,
      "name": promo_campaign.name,
      "promo_registrations": promo_registrations
    }
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
end
