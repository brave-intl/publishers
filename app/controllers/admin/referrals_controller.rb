module Admin
  class ReferralsController < AdminController
    include PromosHelper
    include PublishersHelper
    def show
      publisher = Publisher.find(params[:id])
      @navigation_view = Views::Admin::NavigationView.new(publisher).as_json.merge({ navbarSelection: "Referrals" }).to_json
      respond_to do |format|
        format.html do
          @data = show_data(params[:id])
        end
        format.json do
          render json: show_data(params[:id])
        end
      end
    end

    def show_data(id)
      publisher = Publisher.find(id)
      user_id = publisher.id
      name = publisher.name
      status = publisher.last_status_update.status
      promo_registrations = []

      publisher.promo_registrations.each do |promo_registration|
        stats = []
        JSON.parse(promo_registration.stats).each do |stat|
          date = Date.parse(stat["ymd"]).strftime("%m/%d/%Y")
          stats.push({
            date: date,
            downloads: stat["retrievals"],
            installs: stat["first_runs"],
            confirmations: stat["finalized"],
          })
        end
        promo_registrations.push({
          referralCode: promo_registration.referral_code,
          stats: stats,
        })
      end

      {
        referralCodes: promo_registrations,
      }.merge(Views::Admin::NavigationView.new(publisher).as_json)
    end
  end
end
