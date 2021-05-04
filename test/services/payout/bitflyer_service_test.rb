require "test_helper"

class BitflyerServiceTest < ActiveSupport::TestCase
  let(:payout_report) { PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments(Publisher.all)) }

  let(:subject) do
    mock_refresh = MiniTest::Mock.new.expect(:call, [],
                                             [{ bitflyer_connection: publisher.bitflyer_connection }])

    Payout::BitflyerService.new(
      payout_utils_class: Payout::Service,
      refresher: mock_refresh
    ).perform(payout_report: payout_report,
              publisher: publisher)
  end

  before do
    ActionMailer::Base.deliveries.clear
    PotentialPayment.destroy_all
  end

  describe "when publisher does not have a verified channel" do
    let(:publisher) { publishers(:fake1) }

    before { subject }

    it "does not generate a report" do
      assert_equal 0, PotentialPayment.count
    end
  end

  describe "when publisher is suspended" do
    let(:publisher) { publishers(:bitflyer_suspended) }

    before { subject }

    it 'marks the potential payment as suspended' do
      PotentialPayment.all.each { |potential_payment| assert_equal "suspended", potential_payment.status }
      refute_equal PotentialPayment.count, 0
    end
  end

  describe 'when a creator in good standing' do
    let(:publisher) { publishers(:bitflyer_enabled) }

    before do
      subject
    end

    it 'creates potential payments for the right creator' do
      refute_equal PotentialPayment.count, 0
      PotentialPayment.all.each { |potential_payment| assert_equal publisher.id, potential_payment.publisher_id }
    end

    it 'the address is not empty' do
      assert PotentialPayment.all.all? { |potential_payment|
               if potential_payment.kind == ::PotentialPayment::REFERRAL
                 potential_payment.address == publisher.bitflyer_connection.recipient_id
               else
                 potential_payment.address == publisher.channels.verified[0].deposit_id
               end
             }
    end
  end
end
