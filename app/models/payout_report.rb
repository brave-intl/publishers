# typed: ignore

class PayoutReport < ApplicationRecord
  has_paper_trail
  self.per_page = 8

  LEGACY_PAYOUT_REPORT_TRANSITION_DATE = "2018-12-01 09:14:58 -0800".freeze

  STATUS = ["Enqueued", "Complete"].freeze

  MINIMUM_BALANCE_AMOUNT = 0.01
  BAT = "bat".freeze

  has_many :potential_payments
  has_many :payout_messages

  validates_presence_of :expected_num_payments
  validate :acceptable_status

  scope :final, -> {
    where(final: true)
  }

  class << self
    def encryption_key(key: Rails.configuration.pub_secrets[:attr_encrypted_key])
      # Truncating the key due to legacy OpenSSL truncating values to 32 bytes.
      # New implementations should use [Rails.configuration.pub_secrets[:attr_encrypted_key]].pack("H*")
      key.byteslice(0, 32)
    end
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

  def acceptable_status
    return true unless status.present?

    unless STATUS.include?(status) || status.start_with?("Error")
      errors.add(:status, "#{status} is invalid")
    end
  end

  def referral_count
    potential_payments.count - contribution_count
  end

  def manage_expectations
    publishers = Publisher.joins(:uphold_connection).with_verified_channel
    channels = Channel.where(publisher_id: publishers.pluck(:id), verified: true)

    missing_channels = channels.pluck(:id) - potential_payments.pluck(:channel_id)
    missing_publishers = publishers.pluck(:id) - potential_payments.where(channel_id: nil).pluck(:publisher_id)
    {channels: missing_channels, publishers: missing_publishers}
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
