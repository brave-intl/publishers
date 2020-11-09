task :expire_low_performing_promo_codes => :environment do
  puts "Expiring promo codes for non-approved referral codes"

  excluded_pub_ids = [

  ]
  Publisher.where.not(id: excluded_pub_ids).update_all("feature_flags = jsonb_set(feature_flags, '{UserFeatureFlags::PROMO_LOCKOUT_TIME}', to_json('#{14.days.from_now}'::text)::jsonb)")

  puts "Done"
end
