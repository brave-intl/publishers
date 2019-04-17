module Admin
  class PaymentsController < AdminController
    include PromosHelper
    include PublishersHelper
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
      current_contribution_balance = publisher_contribution_bat_balance(publisher)
      current_overall_balance = publisher_overall_bat_balance(publisher)
      downloads = publisher_referral_totals(publisher)[PromoRegistration::RETRIEVALS]
      installs = publisher_referral_totals(publisher)[PromoRegistration::FIRST_RUNS]
      confirmations = publisher_referral_totals(publisher)[PromoRegistration::FINALIZED]

      current_channel_balances = []
      publisher.channels.each do |channel|
        channel_identifier = channel.details.channel_identifier
        channel_title = channel.details.publication_title
        channel_url = channel.details.url
        channel_balance = publisher_channel_bat_balance(publisher, channel_identifier)
        current_channel_balances.push({
          title: channel_title,
          url: channel_url,
          balance: channel_balance,
        })
      end

      {
        publisher: publisher,
        downloads: downloads,
        installs: installs,
        confirmations: confirmations,
        currentReferralBalance: current_referral_balance,
        currentChannelBalances: current_channel_balances,
        currentContributionBalance: current_contribution_balance,
        currentOverallBalance: current_overall_balance,
      }
    end
  end
end
