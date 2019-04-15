module Admin
  class PaymentsController < AdminController
    include PromosHelper
    include PublishersHelper
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
      current_referral_balance = publisher_referral_bat_balance(publisher)
      current_contribution_balance = publisher_channel_bat_balance(publisher, publisher.channels.last.details.channel_identifier)
      promo_registrations = publisher.promo_registrations
      downloads = publisher_referral_totals(publisher)[PromoRegistration::RETRIEVALS]
      installs = publisher_referral_totals(publisher)[PromoRegistration::FIRST_RUNS]
      confirmations = publisher_referral_totals(publisher)[PromoRegistration::FINALIZED]

      {
        publisher: publisher,
        currentReferralBalance: current_referral_balance,
        currentContributionBalance: current_contribution_balance,
      }
    end
  end
end
