namespace :database_updates do
  task add_publisher_id_to_existing_channel_promo_registrations: [:environment] do
    PromoRegistration.channel_owned.find_each do |promo_registration|
      promo_registration.update(publisher_id: promo_registration.channel.publisher.id)
      print "."
    end
  end
end