# typed: ignore
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

    # This is the data as the dashboard displays it, i.e., we mark a download fiinalized today, but the download_ts
    # is what we go off of when generating this report. This means the confirmation is backported 30+ days.
    # The next section will include the report where we group by the finalized_ts, but that's only included
    # _additionally_ in the nightly CSV since the dashboard still groups data by the download_ts. That is, we still need
    # a section in the nightly CSV that matches the data you see on the dashboard.
    csv.append("")

    csv.append(["DownloadDate", "CountryCode", "ReferralCode", "ConfirmationsTotal"].join(","))
    (start_date..end_date).each do |date|
      referral_codes.each do |referral_code|
        result = ReferralDownload.select("sum(total) AS total_for_day, country_code, ymd").where(referral_code: referral_code, owner_id: publisher_id)
          .where(finalized: true)
          .where("ymd = ?", date)
          .group("ymd, country_code").order("ymd desc, country_code asc")

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

    csv.append("")

    csv.append(["ConfirmationDate", "CountryCode", "ReferralCode", "ConfirmationsTotal"].join(","))
    (start_date..end_date).each do |date|
      referral_codes.each do |referral_code|
        result = ReferralDownload.select("sum(total) AS total_for_day, country_code, DATE(finalized_ts) AS finalized_ts").where(referral_code: referral_code, owner_id: publisher_id)
          .where(finalized: true)
          .where("DATE(finalized_ts) = ?", date)
          .group("DATE(finalized_ts), country_code").order("DATE(finalized_ts) asc, country_code asc")

        result.each do |referral_download|
          csv.append(
            [
              referral_download["finalized_ts"].to_date,
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
