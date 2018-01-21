module PromosHelper
  def generate_private_promo_2018q1_auth_url(publisher)
    promo_token = PublisherPromoToken2018q1Generator.new(publisher: publisher).perform
    promo_registrations_url(promo_token: promo_token)
  end

  def active_promo_id
    Rails.application.secrets[:active_promo_id]
  end

  def promo_running?
    Rails.application.secrets[:active_promo_id].present?
  end
end