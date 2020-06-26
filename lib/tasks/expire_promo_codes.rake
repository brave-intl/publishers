task :expire_promo_codes => :environment do
  puts "Expiring promo codes for the following countries"

  publishers = Publisher.joins(:uphold_connection).where(uphold_connections: { country: PromoRegistration::RESTRICTED_COUNTRIES })

  puts "Updating #{publishers.count}"


  publishers.find_each do |publisher|
    feature_flags = publisher.feature_flags
    feature_flags[UserFeatureFlags::PROMO_LOCKOUT_TIME] = 60.days.from_now.strftime("%Y-%m-%d")

    unless publisher.update(feature_flags: feature_flags)
      puts "Could not update the publisher #{publisher.id}. Try again later?"
    end
  end

  puts "Done"
end
