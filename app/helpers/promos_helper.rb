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
    referral_code = "BATS-#{rand(0..1000)}"
    referral_code
  end

  def offline_promo_stats
    {"times"=>[Time.now.to_s], "series"=>{"name"=>"downloads", "values"=>[rand(0..1000)]}}
  end

  def total_possible_referrals(publisher)
    stats = publisher.promo_stats_2018q1
    if publisher.promo_stats_2018q1.blank?
      return 0
    else
      downloads_for_time_periods = stats["series"]["values"]  
      total_downloads = downloads_for_time_periods.inject(0) {|sum, downloads_for_period| sum + downloads_for_period}
      return total_downloads
    end
  end

  def human_referral_url(referral_code)
    base_human_referral_url + referral_code.downcase
  end

  def referral_url(referral_code)
    "https://" + human_referral_url(referral_code)
  end

  def tweet_url(referral_code)
    referral_link = human_referral_url(referral_code)
    twitter_preamble = "https://twitter.com/intent/tweet/?text="
    tweet_content = I18n.t("promo.shared.tweet_content") + "&url=http%3A%2F%2F" + referral_link
    tweet_content_url = tweet_content.gsub(/\s/, '%20')
    full_tweet_url = twitter_preamble + tweet_content_url
    full_tweet_url
  end

  def facebook_url(referral_code)
    referral_link = human_referral_url(referral_code)
    base_facebook_link = "https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2F"
    sharable_facebook_link = base_facebook_link + referral_link
    sharable_facebook_link
  end

  def base_human_referral_url
    Rails.application.secrets[:base_referral_url].to_s + "/"
  end

  def on_channel_type(channel)
    case channel.details_type
    when "YoutubeChannelDetails"
      "#{channel.publication_title.upcase} #{t("promo.shared.on_youtube")}"
    when "TwitchChannelDetails"
      "#{channel.publication_title.upcase} #{t("promo.shared.on_twitch")}"
    when "SiteChannelDetails"
      "#{channel.publication_title.upcase}"
    else
      raise
    end
  end
end