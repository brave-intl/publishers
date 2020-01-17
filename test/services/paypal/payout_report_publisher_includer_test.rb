require "test_helper"
require "webmock/minitest"

class Paypal::PayoutReportPublisherIncluderTest < ActiveJob::TestCase
  include EyeshadeHelper

  before do
    ActionMailer::Base.deliveries.clear
    PotentialPayment.destroy_all
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    @prev_fee_rate = Rails.application.secrets[:fee_rate]

    # Mock out the creation of cards
    stub_request(:get, /cards/).to_return(body: [id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"].to_json)
    stub_request(:post, /cards/).to_return(body: { id: "fb25048b-79df-4e64-9c4e-def07c8f5c04" }.to_json)
    stub_request(:get, /address/).to_return(body: [{ formats: [{ format: "uuid", value: "e306ec64-461b-4723-bf75-015ffc99ebe1" }], type: "anonymous" }].to_json)
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
    Rails.application.secrets[:fee_rate] = @prev_fee_rate
  end

  describe "publisher has a verified channel" do
    before do
      Rails.application.secrets[:api_eyeshade_offline] = false
    end

    describe "when paypal connected" do
      let(:publisher) { publishers(:paypal_connected) }
      let(:should_send_notifications) { true }

      let(:balance_response) do
        [
          {
            account_id: "publishers#uuid:2fcb973c-7f7c-5351-809f-0eed1de17a77",
            account_type: "owner",
            balance: "500.00"
          },
          {
            account_id: "youtube#channel:",
            account_type: "channel",
            balance: "500.00"
          }
        ]
      end

      let(:subject) do
        perform_enqueued_jobs do
          Paypal::PayoutReportPublisherIncluder.new(
            payout_report: PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments(Publisher.all)),
            publisher: publisher,
            should_send_notifications: should_send_notifications).perform
        end
      end

      before do
        Rails.application.secrets[:api_eyeshade_offline] = false
        stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
        subject
      end

      it "creates two potential payments" do
        assert_equal 2, PotentialPayment.count
        PotentialPayment.all.each do |potential_payment|
          refute potential_payment.reauthorization_needed
          refute potential_payment.uphold_member
          refute potential_payment.suspended
          assert 'paypal', potential_payment.wallet_provider
          assert_nil potential_payment.uphold_status
        end
      end
    end
  end
end
