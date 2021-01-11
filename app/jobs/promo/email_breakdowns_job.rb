class Promo::EmailBreakdownsJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: true

  def perform(publisher_id)
    referral_codes = PromoRegistration.where(publisher_id: publisher_id).pluck(:referral_code)
    csv = CSV.parse(Promo::RegistrationStatsReportGenerator.new(
      referral_codes: referral_codes,
      start_date: 1.days.ago.to_date,
      end_date: 1.days.ago.to_date,
      reporting_interval: PromoRegistration::DAILY,
      is_geo: true,
      include_ratios: false
    ).perform)
    new_csv = []
    csv.each do |row|
      row.delete_at(5) # delete the 30-day-confirmation column
      row.delete_at(2) # delete Day column
      new_csv << row.join(",")
    end
    publisher = Publisher.find_by(id: publisher_id)
    PublisherMailer.promo_breakdowns(publisher, new_csv.join("\n")).deliver_now
  end
end
