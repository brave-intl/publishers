task :expire_promo_codes => :environment do
  puts "Expiring promo codes for non-approved referral codes"

  publishers = Publisher.find_by_sql("
    select publishers.id
    from publishers
      left join channels on channels.publisher_id = publishers.id
      left join promo_registrations on promo_registrations.channel_id = channels.id
    where referral_code not in ('ref123')
    group by publishers.id
  ")

  puts "Updating #{publishers.count}"

  publishers.each do |publisher|
    feature_flags = publisher.feature_flags
    feature_flags[UserFeatureFlags::PROMO_LOCKOUT_TIME] = 14.days.from_now

    unless publisher.update(feature_flags: feature_flags)
      puts "Could not update the publisher #{publisher.id}. Try again later?"
    end
  end

  puts "Done"
end
