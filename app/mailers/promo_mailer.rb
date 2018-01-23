class PromoMailer < ApplicationMailer
  include PromosHelper

  def activate_promo_2018q1(publisher)
    @publisher = publisher
    promo_token = publisher.promo_token_2018q1
    @private_promo_2018q1_auth_url = promo_registrations_url(promo_token: promo_token)

    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end
end