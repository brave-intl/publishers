task :expire_low_performing_promo_codes => :environment do |task, args|
  puts "Expiring promo codes for non-approved referral codes"

  # get the timestamp
  target_time = args[0]
  # get the first one until the end
  excluded_pub_ids = args.slice(1, args.length)
  Publisher.where.not(id: excluded_pub_ids).update_all("feature_flags = jsonb_set(feature_flags, '{UserFeatureFlags::PROMO_LOCKOUT_TIME}', to_json('#{target_time}'::text)::jsonb)")

  puts "Done"
end
