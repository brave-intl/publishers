# typed: false
require "test_helper"

class BitflyerServiceTest < ActiveSupport::TestCase
  let(:payout_report) { PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments(Publisher.all)) }

  let(:subject) do
    @results = Payout::BitflyerService.new(
      payout_utils_class: Payout::Service
    ).perform(payout_report: payout_report,
      publisher: publisher)
  end

  describe "when publisher does not have a verified channel" do
    let(:publisher) { publishers(:fake1) }

    before { subject }

    it "does not generate a report" do
      assert_equal 0, @results.length
    end
  end

  describe "when publisher is suspended" do
    let(:publisher) { publishers(:bitflyer_suspended) }

    before { subject }

    it "marks the potential payment as suspended" do
      @results.each { |potential_payment| assert_equal "suspended", potential_payment.status }
      refute_equal @results.length, 0
    end
  end

  describe "when a creator in good standing" do
    let(:publisher) { publishers(:bitflyer_enabled) }

    before do
      subject
    end

    it "creates potential payments for the right creator" do
      refute_equal @results.length, 0
      @results.each { |potential_payment| assert_equal publisher.id, potential_payment.publisher_id }
    end

    it "the address is not empty" do
      assert @results.all? { |potential_payment| publisher.channels.verified.where(deposit_id: potential_payment.address).present? }
    end

    it "sends the display_name unique BF identifier" do
      assert @results.length > 0
      @results.each do |potential_payment|
        assert publisher.bitflyer_connection.display_name.present?
        assert_equal potential_payment.wallet_provider_id, publisher.bitflyer_connection.display_name
        assert_equal potential_payment.wallet_provider, "bitflyer"
      end
    end
  end
end
