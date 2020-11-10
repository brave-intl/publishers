task :expire_low_performing_promo_codes => :environment do
  puts "Expiring promo codes for non-approved referral codes"

  # convert arguments to strings
  ARGV.each { |a| task a.to_s do ; end }

  # get the timestamp
  target_time = ARGV[0]
  # get the first one until the end
  excluded_pub_ids = ARGV.slice(1, ARGV.length)
  # excluding the passed pub ids, set the promo lockout time to first arg
  Publisher.where.not(id: excluded_pub_ids).update_all("feature_flags = jsonb_set(feature_flags, '{UserFeatureFlags::PROMO_LOCKOUT_TIME}', to_json('#{target_time}'::text)::jsonb)")

  puts "Done"
end
