require "test_helper"

class PotentialPaymentTest < ActiveSupport::TestCase
  test "can only pay a channel once for a given payout report" do
    potential_payment = potential_payments(:site)
    potential_payment_copy = potential_payment.dup

    # ensure two payments to the same channel_id within the same report is invalid
    refute potential_payment_copy.valid?
    assert potential_payment_copy.errors.details[:channel_id].any? {|e| e[:error] == :taken}

    # ensure two payments to the same channel_id with two different reports is valid
    new_payout_report = PayoutReport.create()
    potential_payment_copy.payout_report_id = new_payout_report.id
    assert potential_payment_copy.valid?
  end

  test "can only pay a publisher once for a given payout report" do
    potential_payment = potential_payments(:publisher)
    assert potential_payment.valid?

    # ensure a second payment to the same publisher is invalid
    potential_payment_copy = potential_payment.dup
    refute potential_payment_copy.valid?
    assert potential_payment_copy.errors.details[:publisher_id].any? { |e|
      e[:error] == "Publisher #{potential_payment_copy.publisher_id} already included in the payout report #{potential_payment_copy.payout_report_id}."
    }
  end

  test "channel_id is not present if the kind is referral" do
    potential_payment = potential_payments(:publisher)
    potential_payment.channel_id = channels(:verified).id
    refute potential_payment.valid?
  end

  test "potential payments are not deleted when their channel or publisher is destroyed" do
     publisher = publishers(:potentially_paid)
     publisher.channels.each {|c| c.destroy!}
     publisher.destroy!

     potential_payment = potential_payments(:publisher).reload
     assert_equal PotentialPayment.count, 3
   end
end