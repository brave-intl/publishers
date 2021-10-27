namespace :database_updates do
  task remove_duplicate_tips: :environment do
    cached_uphold_tips = CachedUpholdTip.select(:uphold_transaction_id).group(:uphold_transaction_id).having("count(*) > 1")

    cached_uphold_tips.each do |cached_uphold_tip|
      uphold_transaction_id = cached_uphold_tip.as_json["uphold_transaction_id"]

      tips = CachedUpholdTip.where(uphold_transaction_id: uphold_transaction_id)
      tips.each_with_index do |tip, index|
        # Keep the first found
        next if index == 0
        tip.destroy
      end
    end

    puts "Done!"
  end
end
