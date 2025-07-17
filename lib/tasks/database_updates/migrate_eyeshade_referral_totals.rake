namespace :database_updates do
  task migrate_eyeshade_referral_totals: :environment do
    puts "Running eyeshade migration"

    # once we delete the eyshade code, this job will fail and that is intentional
    publishers = Publisher.in_top_referrer_program.map { |p| {id: p.id, total: p.wallet.referral_balance.amount_bat }}
    puts "#{publishers.length} publishers in referral program"

    publishers.each do |pub|
      rt = ReferralTotals.find_or_create_by(publisher_id: pub[:id])
      rt.total = pub[:total]
      rt.save!
    end

    puts "created referral totals"
  end
end
