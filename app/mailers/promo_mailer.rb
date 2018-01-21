class PromoMailer < ApplicationMailer
  include PromosHelper

  def activate_promo_2018q1(publisher)
    @publisher = publisher
    @private_promo_2018q1_auth_url = generate_private_promo_2018q1_auth_url(publisher)

    mail(
      to: @publisher.email,
      subject: default_i18n_subject
    )
  end
end