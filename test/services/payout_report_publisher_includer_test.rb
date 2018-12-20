require "test_helper"
require "webmock/minitest"

class PayoutReportPublisherIncluderTest < ActiveJob::TestCase
  include EyeshadeHelper

  before do
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    @prev_fee_rate = Rails.application.secrets[:fee_rate]
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
    Rails.application.secrets[:fee_rate] = @prev_fee_rate
  end

  api_eyeshade_base_uri = Rails.application.secrets[:api_eyeshade_base_uri]

  def delete_publishers_except(publisher_ids)
    PublisherNote.destroy_all
    Publisher.all.each do |publisher|
      publisher.delete unless publisher_ids.include?(publisher.id)
    end
  end

  test "publisher with verified channel that is not uphold verified is not included in the report" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    payout_report = PayoutReport.create()
    prev_num_potential_payments = PotentialPayment.count

    # Clear database
    publisher = publishers(:youtube_initial) # has verified channel, is not uphold connected
    delete_publishers_except([publisher.id])

    wallet = {"wallet" => {"address" => "ae42daaa-69d8-4400-a0f4-d359279cd3d2"}}
    balances = [
      {
        "account_id" => "publishers#uuid:2fcb973c-7f7c-5351-809f-0eed1de17a77",
        "account_type" => "owner",
        "balance" => "500.00"
      },
      {
        "account_id" => "youtube#channel:",
        "account_type" => "channel",
        "balance" => "500.00"
      }
    ]

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet, balances: balances)

    perform_enqueued_jobs do
      PayoutReportPublisherIncluder.new(payout_report: payout_report,
                                        publisher: publisher,
                                        should_send_notifications: true).perform
    end

    email = ActionMailer::Base.deliveries.last

    # Ensure the correct email is sent
    assert_equal email.subject, I18n.t('publisher_mailer.wallet_not_connected.subject')

    # Ensure empty payout & payments
    assert_equal PotentialPayment.count, prev_num_potential_payments
    assert_equal payout_report.amount, 0
  end

  test "uphold verified publisher with verified channel with no address supplied is not included in the report, and is sent email" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    payout_report = PayoutReport.create()
    prev_num_potential_payments = PotentialPayment.count

    # Clear database
    publisher = publishers(:uphold_connected) # has >1 verified channel, is uphold connected

    delete_publishers_except([publisher.id])

    balances = [
      {
        "account_id" => "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
        "account_type" => "owner",
        "balance" => "20.00"
      },
      {
        "account_id" => "uphold_connected.org",
        "account_type" => "channel",
        "balance" => "20.00"
      },
      {
        "account_id" => "twitch#channel:ucTw",
        "account_type" => "channel",
        "balance" => "20.00"
      },      {
        "account_id" => "twitter#channel:def456",
        "account_type" => "channel",
        "balance" => "20.00"
      }
    ]

    stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balances)

    # Deliver the email
    perform_enqueued_jobs do
      PayoutReportPublisherIncluder.new(payout_report: payout_report,
                                        publisher: publisher,
                                        should_send_notifications: true).perform
    end

    email = ActionMailer::Base.deliveries.last

    # Ensure the correct email is sent
    assert_equal email.subject, I18n.t('publisher_mailer.wallet_not_connected.subject')

    # Ensure payout is empty and no potential payment was created
    assert_equal PotentialPayment.count, prev_num_potential_payments

    assert_equal payout_report.num_payments, 0
    assert_equal payout_report.amount, 0
  end

  test "uphold verified publisher with verified channel with address and balance is included in payout report" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    Rails.application.secrets[:fee_rate] = 0.05

    payout_report = PayoutReport.create(fee_rate: 0.05)

    # Clear database
    publisher = publishers(:uphold_connected) # has >1 verified channel, is uphold connected
    delete_publishers_except([publisher.id])

    wallet = {"wallet" => {"address" => "ae42daaa-69d8-4400-a0f4-d359279cd3d2"}}
    balances = [
      {
        "account_id" => "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
        "account_type" => "owner",
        "balance" => "20.00"
      },
      {
        "account_id" => "uphold_connected.org",
        "account_type" => "channel",
        "balance" => "20.00"
      },
      {
        "account_id" => "twitch#author:ucTw",
        "account_type" => "channel",
        "balance" => "20.00"
      },      {
        "account_id" => "twitter#channel:def456",
        "account_type" => "channel",
        "balance" => "20.00"
      }
    ]

    stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balances, wallet: wallet)

    # Ensure no emails sent
    assert_enqueued_jobs(1) do
      PayoutReportPublisherIncluder.new(payout_report: payout_report,
                                        publisher: publisher,
                                        should_send_notifications: true).perform
    end

    # Ensure data is correct
    assert_equal payout_report.num_payments, publisher.channels.count + 1
    assert_equal payout_report.amount, (80 * BigDecimal('1e18') - ((60 * BigDecimal.new('1e18')) * payout_report.fee_rate)).to_i
    assert_equal payout_report.fees, (60 * BigDecimal('1e18') * payout_report.fee_rate).to_i

    # Ensure individual potential payment data is correct
    PotentialPayment.where(payout_report_id: payout_report.id).each do |potential_payment|
      assert_equal potential_payment.address, wallet["wallet"]["address"]
      assert_equal potential_payment.publisher_id, "#{publisher.id}"
      if potential_payment.kind == PotentialPayment::CONTRIBUTION
        assert_equal potential_payment.amount, (20 * BigDecimal('1e18') - ((20 * BigDecimal.new('1e18')) * payout_report.fee_rate)).to_i.to_s
      elsif potential_payment.kind == PotentialPayment::REFERRAL
        assert_equal potential_payment.amount, (20 * BigDecimal('1e18')).to_i.to_s
      end
    end

    # Run the includer again with same parameters and ensure no extra potential payments
    # were created (idempotence)

    assert_difference -> { PotentialPayment.count }, 0 do
      PayoutReportPublisherIncluder.new(payout_report: payout_report,
                                        publisher: publisher,
                                        should_send_notifications: true).perform
    end
  end
end
