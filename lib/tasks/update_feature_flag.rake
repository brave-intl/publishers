# Updates a feature flag for all publishers
task :update_feature_flag, [:feature_flag, :value] => :environment do |task, args|
  feature_flag = args[:feature_flag].to_sym
  value = args[:value]

  if value.blank?
    puts "Value can not be blank!"
    return
  end

  unless UserFeatureFlags::VALID_FEATURE_FLAGS.include?(feature_flag)
    puts "#{feature_flag} is not a valid feature flag!"
    return
  end

  total = Publisher.all.count
  puts "Setting #{feature_flag} to be #{value} for #{total} publishers"
  feature_flags = {}
  feature_flags[feature_flag] = value

  updated = Publisher.update_all(["feature_flags = feature_flags::jsonb || ?::jsonb", feature_flags.to_json])
  puts "Updated #{updated}"
end
