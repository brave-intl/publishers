class PromoMailer < ApplicationMailer
  include PublishersHelper

  def activate_promo_2018q1(publisher)
    @publisher = publisher
    @private_promo_2018q1_auth_url = generate_private_promo_2018q1_auth_url(publisher)

    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end

  # Maybe move this to publisher helper?
  def generate_private_promo_2018q1_auth_url(publisher)
    promo_token = PublisherPromoToken2018q1Generator.new(publisher: publisher).perform
    promo_registrations_url(promo_token: promo_token)
  end
end