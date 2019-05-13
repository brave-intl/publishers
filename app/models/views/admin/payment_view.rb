module Views
  module Admin
    class PaymentView
      include ActiveModel::Model
      include PromosHelper
      include PublishersHelper

      def initialize(publisher:)
        @publisher = publisher
      end

      def channel_balances
        channel_balances = []
        @publisher.channels.each do |channel|
          channel_identifier = channel.details.channel_identifier
          channel_title = channel.details.publication_title
          channel_url = channel.details.url
          channel_balance = publisher_channel_bat_balance(@publisher, channel_identifier)
          channel_balances.push({
            title: channel_title,
            url: channel_url,
            balance: channel_balance,
          })
        end
        channel_balances
      end

      # TODO, parse transactions here instead of on client side
      def as_json
        {
          current: {
            downloads: publisher_current_referral_totals(@publisher)[PromoRegistration::RETRIEVALS],
            installs: publisher_current_referral_totals(@publisher)[PromoRegistration::FIRST_RUNS],
            confirmations: publisher_current_referral_totals(@publisher)[PromoRegistration::FINALIZED],
            channelBalances: channel_balances,
            referralBalance: publisher_referral_bat_balance(@publisher),
            contributionBalance: publisher_contribution_bat_balance(@publisher),
            overallBalance: publisher_overall_bat_balance(@publisher),

          },
          historic: {
            downloads: publisher_referral_totals(@publisher)[PromoRegistration::RETRIEVALS],
            installs: publisher_referral_totals(@publisher)[PromoRegistration::FIRST_RUNS],
            confirmations: publisher_referral_totals(@publisher)[PromoRegistration::FINALIZED],
            transactions: PublisherStatementGetter.new(publisher: @publisher, statement_period: "all").perform,
          },
        }.merge(NavigationView.new(@publisher).as_json)
      end
    end
  end
end
