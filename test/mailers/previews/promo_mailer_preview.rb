# Preview all emails at https://localhost:3000/rails/mailers
# As of January 2019, the only active email in this lineup seem to be 'new_channel_registered_2018q1' and it fires at the same time as 'verification_done' when a new channel is verified.

class PromoMailerPreview < ActionMailer::Preview

  def activate_promo_2018q1
    publisher = Publisher.first
    publisher.promo_token_2018q1 = "promo auth token 2018q1"
    PromoMailer.activate_promo_2018q1(publisher)
  end
  
  def promo_activated_2018q1_verified
    publisher = Publisher.first
    channel = publisher.channels.first
    referral_code = "BATS-321"
    promo_registration = PromoRegistration.new(channel_id: channel.id,
      promo_id: "free-bats-2018q1",
      kind: "channel",
      publisher_id: publisher.id,
      referral_code: referral_code)
    promo_enabled_channels = publisher.channels.joins(:promo_registration)
    PromoMailer.promo_activated_2018q1_verified(publisher, promo_enabled_channels)
  end

  def new_channel_registered_2018q1
    publisher = Publisher.first
    channel = publisher.channels.first
    referral_code = "BATS-321"
    promo_registration = PromoRegistration.new(channel_id: channel.id,
      promo_id: "free-bats-2018q1",
      kind: "channel",
      publisher_id: publisher.id,
      referral_code: referral_code)
    PromoMailer.new_channel_registered_2018q1(publisher, channel)
  end

end
