class Api::V1::Stats::ReferralCodesController < Api::V1::StatsController
    def index
      data = PromoRegistration.all.map { |promo_registration| promo_registration.referral_code }
      render(status: 200, json: data)
    end
  
    def show
      promo_registration = PromoRegistration.find_by_referral_code!(params[:id])
      channel = Channel.find(promo_registration.channel_id)

      data = {
        "promo_registration_id": promo_registration.id,
        "channel": {
            "channel_id": channel.id,
            "channel_type": channel.type_display,
            "channel_name": channel.publication_title,
            "channel_identifier": channel.details.channel_identifier,
            "channel_url": channel.details.url,
            "channel_stats": channel.details.stats,
            "publisher_id": channel.publisher_id,
            "verified": channel.verified
        }
      }
      render(status: 200, json: data) and return
  
      rescue ActiveRecord::RecordNotFound
        error_response = {
          errors: [{
            status: "404",
            title: "Not Found",
            detail: "Referral code #{params[:id]} not found"
            }]
          }
      render(status: 404, json: error_response) and return
    end
end
  