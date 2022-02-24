# typed: ignore
# frozen_string_literal: true

class Promo::EmailBreakdownsService < BuilderBaseService
  def self.build
    new
  end

  COUNTRY_TO_PAYOUT_REGION = {
    "US" => 1,

    # 2
    # Australia
    "AU" => 2,
    # Canada
    "CA" => 2,
    # France
    "FR" => 2,
    # Germany
    "DE" => 2,
    # Ireland
    "IE" => 2,
    # Japan
    "JP" => 2,
    # New Zealand
    "NZ" => 2,
    # United Kingdom
    "GB" => 2,

    # 3
    # Austria
    "AT" => 3,
    # Belgium
    "BE" => 3,
    # Denmark
    "DK" => 3,
    # Finland
    "FI" => 3,
    # Hong Kong
    "HK" => 3,
    # Israel
    "IL" => 3,
    # Italy
    "IT" => 3,
    # Luxembourg
    "LU" => 3,
    # Malta
    "MT" => 3,
    # Netherlands
    "NL" => 3,
    # Norway
    "NO" => 3,
    # Portugal
    "PT" => 3,
    # Republic of Korea
    "KR" => 3,
    # Singapore
    "SG" => 3,
    # Spain
    "ES" => 3,
    # Sweden
    "SE" => 3,
    # Switzerland
    "CH" => 3,
    # Taiwan
    "TW" => 3,
    #
    # 4
    #
    # Albania
    "AL" => 4,
    # Argentina
    "AR" => 4,
    # Armenia
    "AM" => 4,
    # Azerbaijan
    "AZ" => 4,
    # Belarus
    "BY" => 4,
    # Belize
    "BZ" => 4,
    # Bolivia
    "BO" => 4,
    # Bosnia Herzegovina
    "BA" => 4,
    # Brazil
    "BR" => 4,
    # Bulgaria
    "BG" => 4,
    # Chile
    "CL" => 4,
    # Colombia
    "CO" => 4,
    # Costa Rica
    "CR" => 4,
    # Croatia
    "HR" => 4,
    # Czechia
    "CZ" => 4,
    # Ecuador
    "EC" => 4,
    # El Salvador
    "SV" => 4,
    # Estonia
    "EE" => 4,
    # Georgia
    "GE" => 4,
    # Guatemala
    "GT" => 4,
    # Honduras
    "HN" => 4,
    # Hungary
    "HU" => 4,
    # Latvia
    "LV" => 4,
    # Lithuania
    "LT" => 4,
    # Macedonia
    "MK" => 4,
    # Mexico
    "MX" => 4,
    # Montenegro
    "ME" => 4,
    # Nicaragua
    "NI" => 4,
    # Panama
    "PA" => 4,
    # Paraguay
    "PY" => 4,
    # Peru
    "PE" => 4,
    # Poland
    "PL" => 4,
    # Republic of Moldova
    "MD" => 4,
    # Romania
    "RO" => 4,
    # Russia
    "RU" => 4,
    # Saudi Arabia
    "SA" => 4,
    # Serbia
    "RS" => 4,
    # Slovakia
    "SK" => 4,
    # Turkey
    "TR" => 4,
    # Ukraine
    "UA" => 4,
    # Uruguay
    "UY" => 4
  }

  # Makes a request to the Uphold API to refresh the current access_token
  def call(publisher_id, type)
    # The nightly report just includes the daily activity whereas the monthly
    # tallies up the last couple of months
    referral_codes = PromoRegistration.where(publisher_id: publisher_id).pluck(:referral_code)
    publisher = Publisher.find_by(id: publisher_id)

    case type
    when "nightly"
      end_date = 1.days.ago.to_date
      start_date = publisher.receives_mtd_promo_emails? ? Date.today.at_beginning_of_month.to_date : 1.days.ago.to_date
      start_date = start_date > end_date ? end_date : start_date
    when "monthly"
      end_date = 1.days.ago.to_date
      start_date = 4.months.ago.at_beginning_of_month.to_date
    else
      T.absurd(type)
    end

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

    dashboard_result = []
    (start_date..end_date).each do |date|
      referral_codes.each do |referral_code|
        result = ReferralDownload.select("sum(total) AS total_for_day, country_code, ymd").where(referral_code: referral_code, owner_id: publisher_id)
          .where(finalized: true)
          .where("ymd = ?", date)
          .group("ymd, country_code").order("ymd desc, country_code asc")

        result.each do |referral_download|
          dashboard_result.append(
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

    if dashboard_result.present?
      csv.append("")
      csv.append(["DownloadDate", "CountryCode", "ReferralCode", "ConfirmationsTotal"].join(","))

      dashboard_result.each { |r| csv.append(r) }
    end

    csv.append("")

    csv.append(["ConfirmationDate", "CountryCode", "ReferralCode", "ConfirmationsTotal", "Region"].join(","))
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
              referral_download["total_for_day"],
              COUNTRY_TO_PAYOUT_REGION[referral_download["country_code"]] || 5
            ].join(",")
          )
        end
      end
    end
    PublisherMailer.promo_breakdowns(publisher, csv.join("\n")).deliver_now
    pass(csv)
  end
end
