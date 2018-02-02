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

  def generate_referral_link(referral_code)
    "#{I18n.t("promo.shared.base_referral_link")}/#{referral_code.downcase}"
  end

  def promo_ends_in
    Rails.application.secrets[:promo_end_date].present? ? (Rails.application.secrets[:promo_end_date].to_datetime - DateTime.now).to_i : "∞"
  end

  def total_possible_referrals(publisher)
    stats = publisher.promo_stats_2018q1
    if publisher.promo_stats_2018q1 == "{}"
      return 0
    else
      downloads_for_time_periods = stats["series"]["values"]  
      total_downloads = downloads_for_time_periods.inject(0) {|sum, downloads_for_period| sum + downloads_for_period}
      return total_downloads
    end
  end

  def referral_bonus(publisher)
    total_possible_referrals = total_possible_referrals(publisher)
    promo_bonus_multiplier = Rails.application.secrets[:promo_bonus_multiplier].to_f
    bonus = total_possible_referrals * promo_bonus_multiplier
  end
end