task :expire_promo_codes => :environment do
  puts "Expiring promo codes for non-KYC and the following countries #{PromoRegistration::RESTRICTED_COUNTRIES.join(', ')}"

  publishers = Publisher.find_by_sql("
    select publishers.id
    from publishers
      left join uphold_connections on uphold_connections.publisher_id = publishers.id
      left join channels on channels.publisher_id = publishers.id
      left join promo_registrations on promo_registrations.channel_id = channels.id
      left join paypal_connections on paypal_connections.user_id = publishers.id
    where
      email != ''
      and referral_code != ''
      and referral_code is not null
      and (
          (uphold_connections.is_member = false AND paypal_connections.id is null)
          OR uphold_connections.country IN ('VN', 'RU', 'ID', 'CN', 'UA')
      )
    group by publishers.id
  ")

  puts "Updating #{publishers.count}"

  publishers.each do |publisher|
    feature_flags = publisher.feature_flags
    feature_flags[UserFeatureFlags::REFERRAL_KYC_REQUIRED] = true

    unless publisher.update(feature_flags: feature_flags)
      puts "Could not update the publisher #{publisher.id}. Try again later?"
    end
  end

  puts "Done"
end
