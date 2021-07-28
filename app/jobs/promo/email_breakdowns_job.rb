class Promo::EmailBreakdownsJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: true

  def perform(publisher_id)
    referral_codes = PromoRegistration.where(publisher_id: publisher_id).pluck(:referral_code)
    publisher = Publisher.find_by(id: publisher_id)

    end_date = 1.days.ago.to_date
    start_date = publisher.receives_mtd_promo_emails? ? Date.today.at_beginning_of_month.to_date : 1.days.ago.to_date
    start_date = start_date > end_date ? end_date : start_date

    csv = CSV.parse(Promo::RegistrationStatsReportGenerator.new(
      referral_codes: referral_codes,
      start_date: start_date,
      end_date: end_date,
      reporting_interval: PromoRegistration::DAILY,
      is_geo: true,
      include_ratios: false
    ).perform)
    new_csv = []
    header = true
    csv.each do |row|
      row = row.dup
      row.delete_at(5) # delete the 30-day-confirmation column
      row.delete_at(2) # delete Day column
      if header
        row << "Confirmations received"
        header = false
      else
        row << total_for_date(date: 1.days.ago.to_date,
                              referral_code: row[0],
                              country: "\"" + (row[1] || "") + "\"",
                              publisher_id: publisher_id)
      end
      new_csv << row.join(",")
    end
    PublisherMailer.promo_breakdowns(publisher, new_csv.join("\n")).deliver_now
  end

  def total_for_date(date:, referral_code:, country:, publisher_id:)
    ReferralDownload.where(finalized: true,
                           owner_id: publisher_id,
                           referral_code: referral_code,
                           country: country,
                           ymd: date - 30.days).count
  end
end
