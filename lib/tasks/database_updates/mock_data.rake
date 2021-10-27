require_relative "./referral_code_data"

namespace :database_updates do
  namespace :mock_data do
    task populate_promo_stats: :environment do
      raise unless Rails.env.development?
      puts "Running populate promo stats"

      PromoRegistration.find_each do |promo|
        stats = [REFERRAL_CODES_1, REFERRAL_CODES_2].sample
        stats = stats.each { |x| x["referral_code"] = promo.referral_code }

        date = Date.today
        stats.reverse.each_slice(2).map do |a, b|
          next if a.nil?
          a["ymd"] = date
          next if b.nil?
          b["ymd"] = date

          date -= 1.day

          [a, b]
        end.flatten

        promo.stats = stats.to_json
        if promo.save
          puts "Saved stats to promo #{promo.referral_code}"
        end
      end

      puts "✨ Done"
    end
  end
end
