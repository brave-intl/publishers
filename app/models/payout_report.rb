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
    total_amount_probi = 0
    PayoutReport.all.each do |report|
      total_amount_probi += report.amount.to_i
    end
    
    total_amount_bat = total_amount_probi.to_d / 1E18
    total_amount_bat
  end

  def self.total_fees
    total_fees_probi = 0

    PayoutReport.all.each do |report|
      total_fees_probi += report.fees.to_i
    end

    total_fees_bat = total_fees_probi.to_d / 1E18
    total_fees_bat
  end

  def self.total_payments
    PayoutReport.sum(:num_payments)
  end
end
