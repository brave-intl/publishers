module Admin
  class ReferralsController < AdminController
    include PromosHelper
    def index
      @transfers = ChannelTransfer.paginate(page: params[:page]).order(created_at: :desc)
    end

    def show
      respond_to do |format|
        format.html
        format.json do
          render json: show_data(params[:id])
        end
      end
    end

    def show_data(id)
      publisher = Publisher.find(id)
      promo_registrations = publisher.promo_registrations
      current_referral_balance = publisher_referral_bat_balance(publisher)
      downloads = publisher_referral_totals(publisher)[PromoRegistration::RETRIEVALS]
      installs = publisher_referral_totals(publisher)[PromoRegistration::FIRST_RUNS]
      confirmations = publisher_referral_totals(publisher)[PromoRegistration::FINALIZED]

      {
        publisher: publisher,
        referralCodes: promo_registrations,
        currentReferralBalance: current_referral_balance,
        downloads: downloads,
        installs: installs,
        confirmations: confirmations,
      }
    end
  end
end
