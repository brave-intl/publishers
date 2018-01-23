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
end