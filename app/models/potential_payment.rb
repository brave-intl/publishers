class PotentialPayment < ApplicationRecord
  has_paper_trail

  REFERRAL = "referral"
  CONTRIBUTION = "contribution"

  belongs_to :payout_report
  belongs_to :publisher
  belongs_to :channel

  validates :channel_id, presence: true, if: -> { kind == CONTRIBUTION}
  validates :channel_id, presence: false, if: -> { kind == REFERRAL}
  validates :channel_id, uniqueness: { scope: :payout_report_id }, unless: -> { channel_id.nil? }

  validate :publisher_id_unique_for_referral_payments

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
end