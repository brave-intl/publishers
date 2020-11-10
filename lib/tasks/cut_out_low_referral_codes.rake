task :expire_low_performing_promo_codes => :environment do
  puts "Expiring promo codes for non-approved referral codes"

  # usage:
  # rake expire_low_performing_promo_codes 2020-11-23 ebf60735-19ec-4db9-86f2-b455940e04aa 436b96e5-36ee-49aa-8e44-d3aee5136cf1 ...

  # convert arguments to strings
  ARGV.each { |a| task a.to_s do ; end }

  # get the timestamp
  target_time = ARGV[1]
  # get the first one until the end
  excluded_pub_ids = ARGV.slice(2, ARGV.length)
  # excluding the passed pub ids, set the promo lockout time to first arg
  puts "excluded_pub_ids"
  puts excluded_pub_ids
  Publisher.where.not(id: excluded_pub_ids).update_all("feature_flags = jsonb_set(feature_flags::jsonb, '{#{UserFeatureFlags::PROMO_LOCKOUT_TIME}}'::text[], to_json('#{target_time}'::text)::jsonb, true)")

  puts "Done"
end
