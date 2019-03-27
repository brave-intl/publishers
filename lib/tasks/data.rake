require_relative './referral_code_data'

namespace :data do
  task :populate_promo_stats => :environment do
    PromoRegistration.find_each do |promo|
      stats = [REFERRAL_CODES_1, REFERRAL_CODES_1].sample
      stats = stats.each { |x| x["referral_code"] = promo.referral_code }
      promo.stats = stats.to_json
      if promo.save
        puts "Saved stats to promo #{promo.referral_code}"
      end
    end
  end
end
