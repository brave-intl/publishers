namespace :database_updates do
  task backfill_potential_payments: [:environment] do
    PayoutReport.all.each do |payout_report|
      next if PotentialPayment.where(payout_report_id: payout_report.id).any? # For idempotence
      potential_payments = JSON.parse(payout_report.contents)
      potential_payments.each do |potential_payment|
        begin
          if potential_payment["type"] == "referral"
            # Payment to owner for referrals
            PotentialPayment.create!(publisher_id: potential_payment["owner"].split(Publisher::OWNER_PREFIX)[1],
                                    kind: potential_payment["type"],
                                    name: potential_payment["name"],
                                    address: potential_payment["address"],
                                    amount: potential_payment["probi"],
                                    fees: potential_payment["fees"],
                                    payout_report_id: payout_report.id)
          else
            # Payment for channel contributions
            PotentialPayment.create!(publisher_id: potential_payment["owner"].split(Publisher::OWNER_PREFIX)[1],
                                    channel_id: Channel.find_by_channel_identifier(potential_payment["publisher"]).id,
                                    kind: potential_payment["type"],
                                    name: potential_payment["name"],
                                    address: potential_payment["address"],
                                    amount: potential_payment["probi"],
                                    fees: potential_payment["fees"],
                                    url: potential_payment["URL"],
                                    payout_report_id: payout_report.id)
          end
          print "."
        rescue NoMethodError => e
          Rails.logger.warn("Unable to find channel with id #{potential_payment["publisher"]}, publisher_id #{potential_payment["owner"]} for payout report id #{payout_report.id} for probi #{potential_payment["probi"]}")
        end
      end
    end
  end
end