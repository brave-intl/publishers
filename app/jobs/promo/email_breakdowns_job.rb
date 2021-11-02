class Promo::EmailBreakdownsJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: true

  def perform(publisher_id)
    referral_codes = PromoRegistration.where(publisher_id: publisher_id).pluck(:referral_code)
    publisher = Publisher.find_by(id: publisher_id)

    end_date = 1.days.ago.to_date
    start_date = publisher.receives_mtd_promo_emails? ? Date.today.at_beginning_of_month.to_date : 1.days.ago.to_date
    start_date = start_date > end_date ? end_date : start_date

    csv = []
    csv.append(["Date", "ReferralCode", "Platform", "CountryCode", "DownloadsTotal"].join(","))
    (start_date..end_date).each do |date|
      referral_codes.each do |referral_code|
        result = ReferralDownload.where(referral_code: referral_code, owner_id: publisher_id, ymd: date.strftime("%Y-%m-%d")).pluck(:ymd, :referral_code, :platform, :country_code, :total)
        result.map! { |entry| entry.join(",") }
        csv += result
      end
    end

    csv.append("")

    csv.append(["ConfirmationDate", "CountryCode", "ReferralCode", "ConfirmationsTotal"].join(","))
    (start_date..end_date).each do |date|
      referral_codes.each do |referral_code|
        start_of_day = date.beginning_of_day
        end_of_day = date.end_of_day
        result = ReferralDownload.select("sum(total) AS total_for_day, country_code, ymd").where(referral_code: referral_code, owner_id: publisher_id)
          .where("finalized_ts >= ?", start_of_day)
          .where("finalized_ts <= ?", end_of_day).group("ymd, country_code").order("ymd desc, country_code asc")
        result.each do |referral_download|
          csv.append(
            [
              referral_download["ymd"].to_date,
              referral_download["country_code"],
              referral_code,
              referral_download["total_for_day"]
            ].join(",")
          )
        end
      end
    end
    PublisherMailer.promo_breakdowns(publisher, csv.join("\n")).deliver_now
  end
end
