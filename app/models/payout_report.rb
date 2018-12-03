class PayoutReport < ApplicationRecord
  has_paper_trail
  self.per_page = 8

  LEGACY_PAYOUT_REPORT_TRANSITION_DATE = "2018-12-01 09:14:58 -0800"
  
  attr_encrypted :contents, key: :encryption_key, marshal: true

  has_many :potential_payments

  scope :final, -> {
    where(final: true)
  }

  def encryption_key
    Rails.application.secrets[:attr_encrypted_key]
  end

  def amount
    potential_payments.sum { |potential_payment| potential_payment.amount.to_i }
  end

  def fees
    potential_payments.sum { |potential_payment| potential_payment.fees.to_i }
  end

  def num_payments
    potential_payments.count
  end

  # Updates the JSON summary of the report downloaded by admins
  def update_report_contents
    # Do not update json contents for legacy reports
    return if created_at <= LEGACY_PAYOUT_REPORT_TRANSITION_DATE
    payout_report_json = JsonBuilders::PayoutReportJsonBuilder.new(payout_report: self).build
    self.contents = payout_report_json.to_json
    save!
  end

  class << self
    def total_amount
      PayoutReport.sum { |payout_report| payout_report.amount }
    end

    def total_fees
      PayoutReport.sum { |payout_report| payout_report.fees }
    end

    def total_payments
      PayoutReport.sum { |payout_report| payout_report.num_payments }
    end
  end
end
