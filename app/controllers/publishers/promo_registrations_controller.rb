# frozen_string_literal: true

class Publishers::PromoRegistrationsController < ApplicationController
  include PromosHelper

  before_action :authenticate_publisher!
  before_action :require_publisher_promo_disabled, :require_promo_running, only: %i(create)
  before_action :validate_publisher!

  layout "promo_registrations", only: [:index, :create]

  GROUP_START_DATE = Date.new(2019, 10, 1)

  ORIGINAL_GROUP_ID = '71341fc9-aeab-4766-acf0-d91d3ffb0bfa'

  RETRIEVALS = "RETRIEVALS" # downloads
  FIRST_RUNS = "FIRST_RUNS" # installs
  FINALIZED = "FINALIZED"   # confirmations

  GROUP_CACHE_KEY = "eyeshade-groups"

  def index
    @publisher = current_publisher
    @promo_enabled_channels = @publisher.channels.joins(:promo_registration)
    if Rails.env.development?
      @publisher_promo_status = @publisher.promo_status(promo_running?)
    else
      @publisher_promo_status = :over
    end
  end

  def create
    return unless Rails.env.development?
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

    groups = Rails.cache.fetch(GROUP_CACHE_KEY, expires_in: 1.hour) do
      EyeshadeClient.referrals.groups
    end

    group_counts = group_counts(groups, user, start_date, end_date)

    groups.each do |group|
      group[:counts] = group_counts.dig(group[:id]) || {}
      group[:name] = I18n.t(".promo.dashboard.group", number: group[:name].remove("Group"))
    end

    groups << october_2019_totals(start_date, group_counts)

    render json: {
      groups: groups.compact,
      totals: sum_counts(group_counts.values),
      lastUpdated: publisher_referrals_last_update(user),
    }
  end

  private

  # Internal: Makes a request to Promo Server and aggregates the number of downloads or installs for a given user
  #
  # groups       - the group information from Eyeshade
  # user         - the publisher to find their finalizations
  # start_date   - the beginning of the range to recieve data within
  # end_date     - the end of the range to recieve data within
  #
  # Returns a hash of group_ids and their associated counts, { group_id => count }
  def group_counts(groups, user, start_date, end_date)
    # Create a { country => group_id } mapping hash
    countries = groups.each_with_object({}) do |group, hash|
      group[:codes]&.each { |code| hash[code] = group[:id] }
    end

    country_counts = PromoClient.reporting.geo_stats_by_referral_code(
      referral_codes: user.promo_registrations.map(&:referral_code),
      start_date: start_date,
      end_date: end_date
    )

    # Transpose the group id to the country_counts
    country_counts = country_counts.each { |x| x["group_id"] = countries[x["country_code"]] }

    group_counts = country_counts.
      group_by { |x| x['group_id'] }.
      transform_values! { |v| sum_counts(v) }

    group_counts
  end

  # Internal: Sums an array of referral hashes to get a total account
  #
  # value - An array of referral hashes
  #
  # Examples
  #   sum_counts([{ "retrievals"=>3, "first_runs"=>2, "finalized"=>1 }, { "retrievals"=>5, "first_runs"=>4, "finalized"=>3 }])
  #   # => { "retrievals"=>8, "first_runs"=>6, "finalized"=>4 }
  #
  # Returns a hash with a summed count of retrievals, first_runs, and finalized.
  def sum_counts(value)
    value.reduce(PromoRegistration::BASE_STATS.deep_dup, &PromoRegistration.sum_stats)
  end

  # Internal: In October 2019 we had an instance where users could receive confirmations with the legacy $5 rate along with the new group rates.
  # We need to show users how many confirmations the received in different groups along with the previous rate.
  #
  # month           - the month that was chosen by the user
  # statement       - the group counts from Eyeshade
  #
  # Returns a hash
  def october_2019_totals(month, counts)
    return unless (GROUP_START_DATE...GROUP_START_DATE.at_end_of_month).include?(month)

    legacy_counts = counts.select { |x| x.nil? }.dig(nil)
    {
      id: SecureRandom.uuid,
      name: 'Previous Rate',
      amount: "5.00",
      currency: "USD",
      counts: legacy_counts || {},
    }
  end

  def require_promo_running
    redirect_to promo_registrations_path, action: "index" unless promo_running?
  end

  def require_publisher_promo_disabled
    redirect_to promo_registrations_path, action: "index" if current_publisher.promo_enabled_2018q1
  end

  def validate_publisher!
    return if user.referral_kyc_not_required? && !user.promo_lockout_time_passed?

    redirect_to root_path, flash: { alert: I18n.t('promo.dashboard.ineligible') } unless user.may_register_promo? && !user.promo_lockout_time_passed?
  end

  def user
    return (@user ||= Publisher.find(params[:publisher_id])) if current_publisher.admin?

    @user ||= current_publisher
  end
end
