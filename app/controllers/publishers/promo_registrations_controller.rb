class Publishers::PromoRegistrationsController < ApplicationController
  include PromosHelper

  before_action :authenticate_publisher!
  before_action :require_publisher_promo_disabled, :require_promo_running, only: %i(create)

  layout "promo_registrations", only: [:index, :create]

  GROUP_START_DATE = Date.new(2019, 10, 1)

  def index
    @publisher = current_publisher
    @publisher_promo_status = @publisher.promo_status(promo_running?)
    @promo_enabled_channels = @publisher.channels.joins(:promo_registration)
  end

  def create
    @publisher = current_publisher
    @publisher.promo_enabled_2018q1 = true
    @publisher.save!
    current_publisher.channels.find_each do |channel|
      channel.register_channel_for_promo # Callee does a check
    end
    @promo_enabled_channels = @publisher.channels.joins(:promo_registration)
    @publisher_has_verified_channel = @publisher.has_verified_channel?
  end

  def for_referral_code
    promo_registration = user.promo_registrations.find_by(referral_code: params[:referral_code])

    render :unauthorized and return if promo_registration.nil?
    render json: {
      stats: promo_registration.aggregate_stats,
      data: promo_registration.stats_by_date,
    }
  end

  def overview
    start_date = (params[:month]&.to_date || Date.today).at_beginning_of_month
    end_date = start_date.at_end_of_month

    aggregate_stats = PromoRegistration.stats_for_registrations(
      promo_registrations: user.promo_registrations,
      start_date: start_date,
      end_date: end_date
    )

    groups = Eyeshade::Referrals.new.groups
    statement = Eyeshade::Referrals.new.statement(publisher: user, start_date: start_date, end_date: end_date)

    groups.each do |group|
      group[:count] = statement.select { |s| s[:groupId] == group[:id] }.length
    end

    groups << october_2019_totals(start_date, aggregate_stats, statement)

    render json: {
      groups: groups.compact,
      totals: aggregate_stats,
      lastUpdated: publisher_referrals_last_update(user),
    }
  end

  private

  def require_promo_running
    redirect_to promo_registrations_path, action: "index" unless promo_running?
  end

  def require_publisher_promo_disabled
    redirect_to promo_registrations_path, action: "index" if current_publisher.promo_enabled_2018q1
  end

  # In October 2019 we had an instance where users could receive confirmations with the legacy $5 rate along with the new group rates.
  # We need to show users how many confirmations the received in different groups along with the previous rate.
  #
  # month           - the month that was chosen by the user
  # aggregate_stats - the stats for this particular month
  # statement       - the group counts from Eyeshade
  #
  # Returns a hash
  def october_2019_totals(month, aggregate_stats, statement)
    return unless (GROUP_START_DATE...GROUP_START_DATE.at_end_of_month).include?(month)

    legacy_count = aggregate_stats[PromoRegistration::FINALIZED] - statement.length
    {
      id: SecureRandom.uuid,
      name: 'Previous Rate',
      amount: "5.00",
      currency: "USD",
      count: legacy_count.negative? ? 0 : legacy_count,
    }
  end

  def user
    return Publisher.find(params[:publisher_id]) if current_publisher.admin?

    current_publisher
  end
end
