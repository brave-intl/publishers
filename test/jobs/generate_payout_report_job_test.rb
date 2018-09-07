require "test_helper"

class GeneratePayoutReportJobTest < ActiveJob::TestCase
  before do
    @prev_fee_rate = Rails.application.secrets[:fee_rate]
    @prev_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_eyeshade_offline
    Rails.application.secrets[:fee_rate] = @prev_fee_rate
  end

  api_eyeshade_base_uri = Rails.application.secrets[:api_eyeshade_base_uri]

  def delete_publishers_except(publisher_ids)
    Publisher.all.each do |publisher|
      publisher.delete unless publisher_ids.include?(publisher.id)
    end
  end

  test "generates a payout report" do
    assert_difference 'PayoutReport.count', 1 do
      GeneratePayoutReportJob.perform_now
    end
  end

  test "publishers without verified channels are not included in the report" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    # Clear database
    publisher = publishers(:created) # has no verified channels
    delete_publishers_except([publisher.id])

    payout_report = GeneratePayoutReportJob.perform_now

    assert_equal payout_report.num_payments, 0
    assert_equal payout_report.amount, "0"
    assert_equal JSON.parse(payout_report.contents), []
  end

  test "publisher with verified channel that is not uphold verified is not included in the report" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    # Clear database
    publisher = publishers(:youtube_initial) # has verified channel, is not uphold connected
    delete_publishers_except([publisher.id])

    # Stub /wallet reponse
    wallet_response = {"wallet" => {"address" => "ae42daaa-69d8-4400-a0f4-d359279cd3d2"}}.to_json

    stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
      to_return(status: 200, body: wallet_response, headers: {})

    # Stub /balances response
    balance_response = [
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
    ].to_json

    stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?account=publishers%23uuid:2fcb973c-7f7c-5351-809f-0eed1de17a77&account=youtube%23channel:").
      to_return(status: 200, body: balance_response)

    payout_report = nil

    # Delier the email
    perform_enqueued_jobs do 
      payout_report = GeneratePayoutReportJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last

    # Ensure the correct email is sent
    assert_equal email.subject, I18n.t('publisher_mailer.wallet_not_connected.subject')

    # Ensure empty payout
    assert_equal payout_report.num_payments, 0
    assert_equal payout_report.amount, "0"
    assert_equal JSON.parse(payout_report.contents), []
  end

  test "uphold verified publisher with verified channel with no address supplied is not included in the report, and is sent email" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    # Clear database
    publisher = publishers(:uphold_connected) # has >1 verified channel, is uphold connected

    delete_publishers_except([publisher.id])

    # Stub disconnected /wallet response
    wallet_response = {}.to_json

    stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
      to_return(status: 200, body: wallet_response, headers: {})

    # Stub /balances response
    balance_response = [
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
    ].to_json

    stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
      to_return(status: 200, body: balance_response)

    payout_report = nil

    # Deliver the email
    perform_enqueued_jobs do 
      payout_report = GeneratePayoutReportJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last

    # Ensure the correct email is sent
    assert_equal email.subject, I18n.t('publisher_mailer.wallet_not_connected.subject')

    # Ensure empty payout
    assert_equal payout_report.num_payments, 0
    assert_equal payout_report.amount, "0"
    assert_equal JSON.parse(payout_report.contents), []
  end

  test "uphold verified publisher with verified channel with address and balance is included in payout report" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    Rails.application.secrets[:fee_rate] = 0.05

    # Clear database
    publisher = publishers(:uphold_connected) # has >1 verified channel, is uphold connected
    delete_publishers_except([publisher.id])

    # Stub disconnected /wallet response
    wallet_response = {"wallet" => {"address" => "ae42daaa-69d8-4400-a0f4-d359279cd3d2"}}.to_json

    stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
      to_return(status: 200, body: wallet_response, headers: {})

    # Stub /balances response
    balance_response = [
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
    ].to_json

    stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
      to_return(status: 200, body: balance_response)

    payout_report = nil

    # Ensure no emails sent
    assert_enqueued_jobs(1) do 
      payout_report = GeneratePayoutReportJob.perform_now
    end

    # Ensure data is correct
    assert_equal payout_report.num_payments, publisher.channels.count
    assert_equal payout_report.amount, (60 * BigDecimal('1e18') - ((60 * BigDecimal.new('1e18')) * payout_report.fee_rate)).to_i.to_s
    assert_equal payout_report.fee_rate, 0.05
    assert_equal payout_report.fees, (60 * BigDecimal('1e18') * payout_report.fee_rate).to_i.to_s

    contents = JSON.parse(payout_report.contents)

    # Ensure JSON data is correct
    contents.each do |channel_payout|
      assert_equal channel_payout["address"], JSON.parse(wallet_response)["wallet"]["address"]
      assert_equal channel_payout["transactionId"], payout_report.id
      assert_equal channel_payout["type"], "contribution"
      assert_equal channel_payout["owner"], "#{publisher.owner_identifier}"
      assert_equal channel_payout["altcurrency"], "BAT"
    end
  end

  test "raises error if fee rate not set" do
    Rails.application.secrets[:fee_rate] = nil

    assert_raises do    
      assert_no_difference -> { PayoutReport.count } do
        GeneratePayoutReportJob.perform_now
      end
    end
  end

  test "suspended publisher with balance is not included in payout report" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:suspended)
    delete_publishers_except([publisher])

    payout_report = nil

    perform_enqueued_jobs do 
      payout_report = GeneratePayoutReportJob.perform_now
    end

    assert_equal payout_report.num_payments, 0
  end
end
