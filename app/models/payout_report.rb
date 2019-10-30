class PayoutReport < ApplicationRecord
  has_paper_trail
  self.per_page = 8

  LEGACY_PAYOUT_REPORT_TRANSITION_DATE = "2018-12-01 09:14:58 -0800".freeze

  attr_encrypted :contents, key: :encryption_key, marshal: true

  PAYPAL = "paypal".freeze
  UPHOLD = "uphold".freeze
  KINDS = [PAYPAL, UPHOLD].freeze

  validates_inclusion_of :kind, in: KINDS

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

  def missing_addresses
    potential_payments.to_be_paid.unscope(where: :address).count - potential_payments.to_be_paid.count
  end

  def contribution_count
    potential_payments.pluck(:channel_id).compact.count
  end

  def referral_count
    potential_payments.count - contribution_count
  end

  def manage_expectations
    publishers = Publisher.joins(:uphold_connection).with_verified_channel
    channels = Channel.where(publisher_id: publishers.pluck(:id), verified: true)

    missing_channels = channels.pluck(:id) - potential_payments.pluck(:channel_id)
    missing_publishers = publishers.pluck(:id) - potential_payments.where(channel_id: nil).pluck(:publisher_id)
    { channels: missing_channels, publishers: missing_publishers }
  end

  # Updates the JSON summary of the report downloaded by admins
  def update_report_contents
    # Do not update json contents for legacy reports
    return if created_at <= LEGACY_PAYOUT_REPORT_TRANSITION_DATE
    payout_report_hash = if paypal_report?
      JsonBuilders::PaypalPayoutReportJsonBuilder.new(payout_report: self).build
    elsif manual
      JsonBuilders::ManualPayoutReportJsonBuilder.new(payout_report: self).build
    else
      JsonBuilders::PayoutReportJsonBuilder.new(payout_report: self).build
    end
    self.contents = payout_report_hash.to_json
    save!
  end

  def paypal_report?
    kind == PAYPAL
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
      PayoutReport.all.where(final: true, manual: false).order("created_at").last
    end

    def expected_num_payments(publishers)
      channels = Channel.where(publisher_id: publishers.pluck(:id), verified: true)
      publishers.with_verified_channel.count + channels.count
    end
  end
end
