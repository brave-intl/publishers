class PayoutReport < ApplicationRecord
  has_paper_trail
  self.per_page = 8

  LEGACY_PAYOUT_REPORT_TRANSITION_DATE = "2018-12-01 09:14:58 -0800"

  attr_encrypted :contents, key: :encryption_key, marshal: true

  has_many :potential_payments

  validates_presence_of :expected_num_payments

  scope :final, -> {
    where(final: true)
  }

  def encryption_key
    # Truncating the key due to legacy OpenSSL truncating values to 32 bytes.
    # New implementations should use [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
    Rails.application.secrets[:attr_encrypted_key].byteslice(0, 32)
  end

  def amount
    potential_payments.to_be_paid.sum { |potential_payment| potential_payment.amount.to_i }
  end

  def fees
    potential_payments.to_be_paid.sum { |potential_payment| potential_payment.fees.to_i }
  end

  def num_payments
    potential_payments.count
  end

  def num_payments_to_be_paid
    potential_payments.to_be_paid.count
  end

  # Updates the JSON summary of the report downloaded by admins
  def update_report_contents
    # Do not update json contents for legacy reports
    return if created_at <= LEGACY_PAYOUT_REPORT_TRANSITION_DATE
    payout_report_hash = JsonBuilders::PayoutReportJsonBuilder.new(payout_report: self).build
    self.contents = payout_report_hash.to_json
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

    def most_recent_final_report
      PayoutReport.all.where(final: true).order("created_at").last
    end

    def expected_num_payments
      Publisher.with_verified_channel.count + Channel.verified.count
    end
  end
end
