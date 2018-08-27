class PayoutReport < ApplicationRecord
  has_paper_trail
  self.per_page = 8
  
  attr_encrypted :contents, key: :encryption_key, marshal: true

  scope :final, -> {
    where(final: true)
  }

  def encryption_key
    Rails.application.secrets[:attr_encrypted_key]
  end

  def self.total_amount
    PayoutReport.sum { |payout_report| payout_report.amount.to_i } / 1E18
  end

  def self.total_fees
    PayoutReport.sum { |payout_report| payout_report.fees.to_i } / 1E18
  end

  def self.total_payments
    PayoutReport.sum(:num_payments)
  end
end
