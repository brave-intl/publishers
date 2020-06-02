require 'pry'

task :expire_promo_codes => :environment do
  puts "Expiring promo codes for the following countries"

  publishers = Publisher.joins(:uphold_connection).where(uphold_connections: { country: PromoRegistration::RESTRICTED_COUNTRIES })

  puts "Updating #{publishers.count}"

  updated = publishers.update(promo_expiration_time: 60.days.from_now)
  if updated
    puts 'Successfully updated'
  else
    puts 'Could not update the publishers. Try again later?'
  end

  puts "Done"
end
