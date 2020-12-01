class Promo::EmailBreakdownsJob
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: true

  def perform(publisher_id)
    referral_codes = PromoRegistration.where(publisher_id: publisher_id).pluck(:referral_code)
    csv = Promo::RegistrationStatsReportGenerator.new(
      referral_codes: referral_codes,
      start_date: 4.days.ago.to_date,
      end_date: 1.days.ago.to_date,
      reporting_interval: PromoRegistration::DAILY,
      is_geo: true
    ).perform
    publisher = Publisher.find_by(id: publisher_id)
    PublisherMailer.promo_breakdowns(publisher, csv).deliver_now
  end
end
