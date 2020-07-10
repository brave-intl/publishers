require 'test_helper'
require "webmock/minitest"

class PayoutReportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include EyeshadeHelper

  let(:uphold_url) { Rails.application.secrets[:uphold_api_uri] + "/v0/me" }

  before do
    @prev_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    stub_request(:get, uphold_url).to_return(body: { status: "ok", memberAt: "2019", uphold_id: "123e4567-e89b-12d3-a456-426655440000" }.to_json)

    # Mock out the creation of cards
    stub_request(:get, /cards/).to_return(body: [id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"].to_json)
    stub_request(:post, /cards/).to_return(body: { id: "fb25048b-79df-4e64-9c4e-def07c8f5c04" }.to_json)
    stub_request(:get, /address/).to_return(body: [{ formats: [{ format: "uuid", value: "e306ec64-461b-4723-bf75-015ffc99ebe1" }], type: "anonymous" }].to_json)
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_eyeshade_offline
  end

  def delete_publishers_except(publisher_ids)
    PublisherNote.destroy_all
    Publisher.all.each do |publisher|
      publisher.delete unless publisher_ids.include?(publisher.id)
    end
  end

  test "#create launches EnqueuePublishersForPayoutJob for admin" do
    admin = publishers(:admin)
    sign_in admin

    assert_enqueued_with(job: EnqueuePublishersForPayoutJob) do
      post admin_payout_reports_path
    end
  end

  test "#create doesn't send email or set final if no params are present in POST" do
    admin = publishers(:admin)
    sign_in admin

    publisher = publishers(:uphold_connected)
    delete_publishers_except([admin.id, publisher.id])

    # Stub disconnected /wallet response
    wallet_response = {"wallet" => {"address" => "ae42daaa-69d8-4400-a0f4-d359279cd3d2"}}.to_json

    stub_request(:get, /v1\/owners\/#{URI.encode_www_form_component(publisher.owner_identifier)}\/wallet/).
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

    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456&pending=true").
      to_return(status: 200, body: balance_response)
    assert_difference("PayoutReport.count", 1) do
      assert_difference("ActionMailer::Base.deliveries.count", 0) do
        perform_enqueued_jobs do
          post admin_payout_reports_path
        end
      end
    end

    # Ensure payout report was not marked as final
    refute PayoutReport.order(created_at: :desc).first.final
  end

  test "#create generates final payout report if final flag is set" do
    admin = publishers(:admin)
    sign_in admin

    publisher = publishers(:uphold_connected)
    delete_publishers_except([admin.id, publisher.id])

    # Stub disconnected /wallet response
    wallet_response = {"wallet" => {"address" => "ae42daaa-69d8-4400-a0f4-d359279cd3d2"}}.to_json

    stub_request(:get, /v1\/owners\/#{URI.encode_www_form_component(publisher.owner_identifier)}\/wallet/).
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

    stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456&pending=true").
      to_return(status: 200, body: balance_response)

    assert_difference("PayoutReport.count", 1) do
      assert_difference("ActionMailer::Base.deliveries.count", 0) do
        perform_enqueued_jobs do
          post admin_payout_reports_path(final: true)
        end
      end
    end

    # Ensure payout report was not marked as final
    assert PayoutReport.order(created_at: :desc).first.final
  end

  test "#download inserts the admin's email as the authority" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    admin = publishers(:admin)
    publisher = publishers(:uphold_connected)
    delete_publishers_except([admin.id, publisher.id])
    sign_in admin


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
        "account_id" => "twitch#channel:ucTw",
        "account_type" => "channel",
        "balance" => "20.00"
      },      {
        "account_id" => "twitter#channel:def456",
        "account_type" => "channel",
        "balance" => "20.00"
      }
    ]

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet, balances: balances)

    # Create the non blank payout report
    perform_enqueued_jobs do
      post admin_payout_reports_path(final: true)
    end

    # Ensure authority is the admin's email when the file is downloaded
    payout_report = PayoutReport.all.order(created_at: :desc).first
    payout_report.update_report_contents
    get download_admin_payout_report_path(payout_report)
    JSON.parse(response.body).each { |channel| assert_equal channel["authority"], admin.email}
  end

  test "#create sends email if should_send_notifications flag is set" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    admin = publishers(:admin)
    publisher = publishers(:uphold_connected)
    delete_publishers_except([admin.id, publisher.id])
    sign_in admin

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

    assert_difference("PayoutReport.count", 1) do
      assert_difference("ActionMailer::Base.deliveries.count", 0) do
        perform_enqueued_jobs do
          post admin_payout_reports_path(final: true, should_send_notifications: true)
        end
      end
    end
  end

  test "#refresh refreshes report contents" do
    admin = publishers(:admin)
    sign_in admin
    payout_report = payout_reports(:one)

    assert_enqueued_with(job: UpdatePayoutReportContentsJob) do
      patch refresh_admin_payout_report_path(payout_report.id)
    end
  end

  test "#notify sends emails to" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    admin = publishers(:admin)
    publisher = publishers(:completed)
    delete_publishers_except([admin.id, publisher.id])
    sign_in admin

    # Stub disconnected /wallet response
    wallet_response = {}

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
    ]

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet_response, balances: balance_response)

    assert_difference("PayoutReport.count", 0) do # Ensure no payout report is created
      assert_difference("ActionMailer::Base.deliveries.count", 1) do # ensure notification is sent
        perform_enqueued_jobs do
          Sidekiq::Testing.inline! do
            post notify_admin_payout_reports_path
          end
        end
      end
    end
  end

  describe "#upload_settlement_report" do
    before do
      admin = publishers(:admin)
      sign_in admin
    end

    describe 'when user uploads a bad JSON file' do
      let(:file) { fixture_file_upload(Rails.root.join('test','fixtures', '1x1.png')) }

      before do
        post upload_settlement_report_admin_payout_reports_path,
          params: { file: file },
          headers: { 'content-type': 'multipart/form-data' }
      end

      it 'alerts failure' do
        assert_includes flash[:alert],"Could not parse JSON."
      end
    end

    describe 'when user uploads a valid JSON file' do
      let(:json_file) { fixture_file_upload(Rails.root.join("test","fixtures", "files", "test.json")) }

      before do
        post upload_settlement_report_admin_payout_reports_path,
          params: { file: json_file },
          headers: { 'content-type': 'multipart/form-data' }
      end

      it 'alerts sucess' do
        assert_equal "Successfully uploaded settlement report", flash[:notice]
      end
    end
  end

  describe "#toggle_payout_in_progress" do
    before do
      admin = publishers(:admin)
      sign_in admin
    end

    describe "when payout not in progress" do
      before do
        Rails.cache.write('payout_in_progress', false)
        post toggle_payout_in_progress_admin_payout_reports_path
      end

      it "set payout in progress" do
        assert Rails.cache.fetch('payout_in_progress')
      end
    end

    describe "when payout in progress" do
      before do
        Rails.cache.write('payout_in_progress', true)
        post toggle_payout_in_progress_admin_payout_reports_path
      end

      it "set payout in progress" do
        refute Rails.cache.fetch('payout_in_progress')
      end
    end  end
end
