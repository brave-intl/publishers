class PotentialPayment < ApplicationRecord
  REFERRAL = "referral"
  CONTRIBUTION = "contribution"

  belongs_to :payout_report
  belongs_to :publisher
  belongs_to :channel

  validates :channel_id, presence: true, if: -> { kind == CONTRIBUTION}
  validates :channel_id, uniqueness: { scope: :payout_report_id }, unless: -> { channel_id.nil? }
  validate :channel_id_not_present_for_referral_payment, if: -> { kind == REFERRAL }
  validate :publisher_id_unique_for_referral_payments

  validates_inclusion_of :reauthorization_needed, :suspended, :uphold_member, :in => [true, false]

  scope :to_be_paid, -> {
    where(uphold_status: "ok", reauthorization_needed: false, uphold_member: true, suspended: false).
    where("amount::numeric > ?", 0)
  }

  private

  def publisher_id_unique_for_referral_payments
    referral_payment_for_publisher_already_exists = PotentialPayment.where(payout_report_id: payout_report_id).
                                                                     where(kind: REFERRAL).
                                                                     where(publisher_id: publisher_id).
                                                                     where.not(id: id).any?
    if referral_payment_for_publisher_already_exists && kind == REFERRAL
      errors.add(:publisher_id, "Publisher #{publisher_id} already included in the payout report #{payout_report_id}.")
    end
  end

  def channel_id_not_present_for_referral_payment
    unless channel_id.nil?
      errors.add(:channel_id, "Referral payments can't have a channel_id for potential_payment='#{id}'")
    end
  end
end
