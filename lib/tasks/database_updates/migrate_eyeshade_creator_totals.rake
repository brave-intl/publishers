namespace :database_updates do
  task :migrate_eyeshade_referral_totals, [:channel_identifiers] do
    puts "Running eyeshade migration"

    # once we delete the eyshade code, this job will fail and that is intentional
    publishers = Publisher.joins(:channels)
      .where(channels: { derived_brave_publisher_id: [:channel_identifiers] })
      .distinct
      .map { |p| {id: p.id, total: p.wallet&.overall_balance&.amount_bat} }

    puts "#{publishers.length} publishers found from channel list"

    publishers.each do |pub|
      # this job should only be run once, but protect against duplicates just in case
      rt = CreatorTotals.find_or_create_by(publisher_id: pub[:id])
      rt.total = pub[:total]
      rt.save!
    end

    puts "created creator totals"
  end
end
