module PromosHelper
  def active_promo_id
    Rails.application.secrets[:active_promo_id]
  end

  def promo_running?
    Rails.application.secrets[:active_promo_id].present?
  end

  def perform_promo_offline?
    Rails.application.secrets[:api_promo_base_uri].blank?
  end

  def offline_referral_code
    referral_code = "BATS-#{rand(0..10000)}"
    referral_code
  end

  def offline_promo_stats
    { "times" => [Time.now.to_s], "series" => { "name" => "downloads", "values" => [rand(0..1000)] }, "aggregate" => { "downloads" => 200, "finalized" => 30 } }
  end

  def publisher_referral_totals(publisher)
    aggregate_stats = PromoRegistration.aggregate_stats(publisher.promo_registrations)

    {
      PromoRegistration::RETRIEVALS => aggregate_stats[PromoRegistration::RETRIEVALS],
      PromoRegistration::FIRST_RUNS => aggregate_stats[PromoRegistration::FIRST_RUNS],
      PromoRegistration::FINALIZED => aggregate_stats[PromoRegistration::FINALIZED],
    }
  end

  def publisher_current_referral_totals(publisher)
    retrievals = 0
    first_runs = 0
    finalized = 0
    cutoff = Date.today.beginning_of_month
    publisher.promo_registrations.each do |promo_registration|
      JSON.parse(promo_registration.stats).each do |stat|
        if Date.parse(stat["ymd"]) > cutoff
          retrievals += stat["retrievals"]
          first_runs += stat["first_runs"]
          finalized += stat["finalized"]
        end
      end
    end
    {
      PromoRegistration::RETRIEVALS => retrievals,
      PromoRegistration::FIRST_RUNS => first_runs,
      PromoRegistration::FINALIZED => finalized,
    }
  end

  def referral_url(referral_code)
    base_referral_url + referral_code.downcase
  end

  def https_referral_url(referral_code)
    "https://" + base_referral_url + referral_code.downcase
  end

  def tweet_url(referral_code)
    referral_link = referral_url(referral_code)
    twitter_preamble = "https://twitter.com/intent/tweet/?text="
    tweet_content = I18n.t("promo.shared.tweet_content") + "&url=https%3A%2F%2F" + referral_link
    tweet_content_url = tweet_content.gsub(/\s/, '%20')
    full_tweet_url = twitter_preamble + tweet_content_url
    full_tweet_url
  end

  def facebook_url(referral_code)
    referral_link = referral_url(referral_code)
    base_facebook_link = "https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2F"
    sharable_facebook_link = base_facebook_link + referral_link
    sharable_facebook_link
  end

  def base_referral_url
    Rails.application.secrets[:base_referral_url].to_s + "/"
  end

  def on_channel_type(channel)
    case channel.details_type
    when "SiteChannelDetails"
      "#{channel.publication_title.upcase}"
    else
      "#{channel.publication_title.upcase} #{t("promo.shared.on_#{channel.type_display.downcase}")}"
    end
  end

  def reporting_interval_column_header(reporting_interval)
    case reporting_interval
    when PromoRegistration::DAILY
      "Day"
    when PromoRegistration::WEEKLY
      "Week"
    when PromoRegistration::MONTHLY
      "Month"
    when PromoRegistration::RUNNING_TOTAL
      "Date"
    else
      raise "Invalid reporting interval #{reporting_interval}"
    end
  end

  def event_type_column_header(event_type)
    case event_type
    when PromoRegistration::RETRIEVALS
      "Downloads"
    when PromoRegistration::FIRST_RUNS
      "First opens"
    when PromoRegistration::FINALIZED
      "30 days"
    else
      raise
    end
  end

  def ratios_column_header(is_geo)
    if is_geo
      ["Referral code", "Country", "Downloads", "Installs", "Eligible Installs", "30 days", "Installs / Downloads", "30 days / Eligible Installs"]
    else
      ["Referral code", "Downloads", "Installs", "Eligible Installs", "30 days", "Installs / Downloads", "30 days / Eligible Installs"]
    end
  end

  def coerce_date_to_start_or_end_of_reporting_interval(date, reporting_interval, start)
    case reporting_interval
    when PromoRegistration::DAILY, PromoRegistration::RUNNING_TOTAL
      date
    when PromoRegistration::WEEKLY
      start ? date.at_beginning_of_week : date.at_end_of_week
    when PromoRegistration::MONTHLY
      start ? date.at_beginning_of_month : date.at_end_of_month
    else
      raise
    end
  end
end
