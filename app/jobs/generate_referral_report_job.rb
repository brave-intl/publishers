# typed: ignore

class GenerateReferralReportJob < ApplicationJob
  queue_as :scheduler

  def perform(publisher_id:, referral_codes:, start_date:, end_date:, interval:, break_down_by_country:)
    report_csv = Promo::RegistrationStatsReportGenerator.new(
      referral_codes: referral_codes,
      start_date: start_date,
      end_date: end_date,
      reporting_interval: interval,
      is_geo: break_down_by_country
    ).perform

    filename = "tmp/#{Time.now}_referral_report_#{start_date}-#{end_date}.csv"
    File.write(filename, report_csv)

    email = Publisher.find(publisher_id).email

    InternalMailer.email_report(
      email: email,
      filename: filename,
      subject: "#{interval.titleize} Referral Report  for #{referral_codes.length} codes between #{start_date} and #{end_date}",
      body: "This report contains information for the following referral codes \n\n" \
        "#{referral_codes.join("\n")} \n\n" \
        "Reporting Interval: #{interval} \n" \
        "Range: #{start_date} through #{end_date} "
    ).deliver_now

    File.delete(filename)
  end
end
