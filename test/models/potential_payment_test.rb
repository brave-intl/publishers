require "test_helper"

class PotentialPaymentTest < ActiveSupport::TestCase
  test "can only pay a channel once for a given payout report" do
    potential_payment = potential_payments(:site)
    potential_payment_copy = potential_payment.dup

    # ensure two payments to the same channel_id within the same report is invalid
    refute potential_payment_copy.valid?
    assert potential_payment_copy.errors.details[:channel_id].any? {|e| e[:error] == :taken}

    # ensure two payments to the same channel_id with two different reports is valid
    new_payout_report = PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments)
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

  test "to_be_paid scope only includes 'ok' uphold status" do
    potential_payment = potential_payments(:site)
    assert PotentialPayment.to_be_paid.include?(potential_payment)

    potential_payment.update!(uphold_status_was: "restricted")
    refute PotentialPayment.to_be_paid.include?(potential_payment)
  end

  test "to_be_paid scope does not include suspended" do
    potential_payment = potential_payments(:site)
    potential_payment.update!(was_suspended: true)
    refute PotentialPayment.to_be_paid.include?(potential_payment)
  end

  test "to_be_paid scope excludes unless reauthorization was needed" do
    potential_payment = potential_payments(:site)
    potential_payment.update!(reauthorization_was_needed: true)
    refute PotentialPayment.to_be_paid.include?(potential_payment)
  end

  test "to_be_paid scope excludes unless was uphold member" do
    potential_payment = potential_payments(:site)
    potential_payment.update!(was_uphold_member: false)
    refute PotentialPayment.to_be_paid.include?(potential_payment)
  end
end
