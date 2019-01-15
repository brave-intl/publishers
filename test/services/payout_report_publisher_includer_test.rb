require "test_helper"
require "webmock/minitest"

class PayoutReportPublisherIncluderTest < ActiveJob::TestCase
  before do
    ActionMailer::Base.deliveries.clear 
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

  describe 'when publisher does not have a verified channel' do
    it 'does not generate a report' do

    end
  end

  describe 'when publisher is suspended' do
    it 'does not generate a report' do
    end
  end

  describe 'publisher has a verified channel' do
    before do
      Rails.application.secrets[:api_eyeshade_offline] = false
      PotentialPayment.destroy_all
    end

    describe 'when not uphold verified' do
      let(:publisher) { publishers(:youtube_initial) }
      let(:should_send_notifications) { true }
      let(:wallet_response) { {} }

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
          PayoutReportPublisherIncluder.new(payout_report: PayoutReport.create,
                                            publisher: publisher,
                                            should_send_notifications: should_send_notifications).perform
        end
      end

      before do
        account_ids = balance_response.map { |x| "account=#{x[:account_id]}" }.join("&")

        stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
          to_return(status: 200, body: wallet_response.to_json, headers: {})

        stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?#{account_ids}").
          to_return(status: 200, body: balance_response.to_json)

        subject
      end

      it 'is not included in the report' do
        assert_equal 0, PotentialPayment.count
      end

      it 'sends email to connect uphold' do
        email = ActionMailer::Base.deliveries.last
        assert_equal email&.subject, I18n.t('publisher_mailer.wallet_not_connected.subject')
      end
    end

    describe 'when uphold verified' do
      let(:publisher) { publishers(:uphold_connected) }
      let(:subject) do
        perform_enqueued_jobs do
          PayoutReportPublisherIncluder.new(payout_report: @payout_report,
                                            publisher: publisher,
                                            should_send_notifications: should_send_notifications).perform
        end
      end

        # All members should have addresses 
      describe 'with address' do
        describe 'with balance' do
          let(:balance_response) do
            [
              {
                account_id: "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
                account_type: "owner",
                balance: "20.00"
              },
              {
                account_id: "uphold_connected.org",
                account_type: "channel",
                balance: "20.00"
              },
              {
                account_id: "twitch#author:ucTw",
                account_type: "channel",
                balance: "20.00"
              },      {
                account_id: "twitter#channel:def456",
                account_type: "channel",
                balance: "20.00"
              }
            ]
          end

          before do
            Rails.application.secrets[:fee_rate] = 0.05
            @payout_report = PayoutReport.create(fee_rate: 0.05)

            account_ids = balance_response.map { |x| "account=#{x[:account_id]}" }.join("&")
            stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?#{URI.escape(account_ids)}").
              to_return(status: 200, body: balance_response.to_json)
          end

          # Edge case when user has reached uphold transaction limits
          describe 'when is a member and restricted' do
            let(:wallet_response) do
              { wallet: { authorized: false, address: "ae42daaa-69d8-4400-a0f4-d359279cd3d2", status: "restricted", "isMember": true } }
            end

            before do
              stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
                to_return(status: 200, body: wallet_response.to_json, headers: {})
            end

            describe 'when should_send_notifications is false' do
              let(:should_send_notifications) { false }

              before do
                subject
              end
              
              it 'does not include in report' do
                assert_equal 0, PotentialPayment.count
                assert_equal 0, payout_report.amount
              end

              it 'sends no emails' do
                assert_empty ActionMailer::Base.deliveries 
              end
            end

            describe 'when should_send_notifications is true' do
              let(:should_send_notifications) { true }

              before do
                subject
              end
              
              it 'does not include in report' do
                assert_equal 0, PotentialPayment.count
                assert_equal 0, @payout_report.amount
              end

              it 'sends an email notifying restricted' do
                assert ActionMailer::Base.deliveries.present?
              end
            end
          end

          describe 'when is a member' do
            let(:wallet_response) do
              { wallet: { authorized: true, address: "ae42daaa-69d8-4400-a0f4-d359279cd3d2", status: "ok", "isMember": true } }
            end

            describe 'when should_send_notifications is false' do
              let(:should_send_notifications) { false }

              before do
                stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
                  to_return(status: 200, body: wallet_response.to_json, headers: {})

                subject
              end

              it 'is included in payout report' do
                assert_equal @payout_report.num_payments, publisher.channels.count + 1
                assert_equal @payout_report.amount, (80 * BigDecimal('1e18') - ((60 * BigDecimal.new('1e18')) * @payout_report.fee_rate)).to_i
                assert_equal @payout_report.fees, (60 * BigDecimal('1e18') * @payout_report.fee_rate).to_i
              end

              it 'has the correct content' do
                PotentialPayment.where(payout_report_id: @payout_report.id).each do |potential_payment|
                  assert_equal potential_payment.address, wallet_response[:wallet][:address]
                  assert_equal potential_payment.publisher_id,  publisher.id.to_s
                  if potential_payment.kind == PotentialPayment::CONTRIBUTION
                    assert_equal potential_payment.amount, (20 * BigDecimal('1e18') - ((20 * BigDecimal.new('1e18')) * @payout_report.fee_rate)).to_i.to_s
                  elsif potential_payment.kind == PotentialPayment::REFERRAL
                    assert_equal potential_payment.amount, (20 * BigDecimal('1e18')).to_i.to_s
                  end
                end
              end

              it 'does not create any extra payments' do
                assert_difference -> { PotentialPayment.count }, 0 do
                  PayoutReportPublisherIncluder.new(payout_report: @payout_report,
                                                    publisher: publisher,
                                                    should_send_notifications: should_send_notifications).perform
                end
              end

              it 'sends no emails' do
                assert_empty ActionMailer::Base.deliveries 
              end
            end

            describe 'when should_send_notifications is true' do
              let(:should_send_notifications) { true }

              before do
                subject
              end

              # This is the happy path, the publisher is in the happy state and does not need any additional contact.
              it 'sends no emails' do
                assert_empty ActionMailer::Base.deliveries 
              end

              it 'is not included in payout report' do
                assert_equal @payout_report.num_payments, publisher.channels.count + 1
                assert_equal @payout_report.amount, (80 * BigDecimal('1e18') - ((60 * BigDecimal.new('1e18')) * @payout_report.fee_rate)).to_i
                assert_equal @payout_report.fees, (60 * BigDecimal('1e18') * @payout_report.fee_rate).to_i
              end

              it 'has the correct content' do
                PotentialPayment.where(payout_report_id: @payout_report.id).each do |potential_payment|
                  assert_equal potential_payment.address, wallet_response[:wallet][:address]
                  assert_equal potential_payment.publisher_id, publisher.id.to_s
                  if potential_payment.kind == PotentialPayment::CONTRIBUTION
                    assert_equal potential_payment.amount, (20 * BigDecimal('1e18') - ((20 * BigDecimal.new('1e18')) * @payout_report.fee_rate)).to_i.to_s
                  elsif potential_payment.kind == PotentialPayment::REFERRAL
                    assert_equal potential_payment.amount, (20 * BigDecimal('1e18')).to_i.to_s
                  end
                end
              end

              it 'does not create any extra payments' do
                assert_difference -> { PotentialPayment.count }, 0 do
                  PayoutReportPublisherIncluder.new(payout_report: @payout_report,
                                                    publisher: publisher,
                                                    should_send_notifications: should_send_notifications).perform
                end
              end
            end
          end

          describe 'not a member' do
            # Possible that user  
            let(:wallet_response) do
              { wallet: { authorized: false, address: "ae42daaa-69d8-4400-a0f4-d359279cd3d2", status: "restricted", "isMember": false } }
            end

            before do
              stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
                to_return(status: 200, body: wallet_response.to_json, headers: {})
            end
            
            describe 'should_send_notifications is true' do
              let(:should_send_notifications) { true }

              before do
                subject
              end

              it 'does not include in report' do
                assert_equal 0, PotentialPayment.count
                assert_equal 0, @payout_report.amount
              end

              it 'receives KYC email' do
                email = ActionMailer::Base.deliveries.last
                assert_equal email.subject, I18n.t('publisher_mailer.uphold_kyc_incomplete.subject')
              end
            end

            describe 'should_send_notifications is false' do
              let(:should_send_notifications) { false }

              before do
                subject
              end

              it 'does not include in report' do
                assert_equal 0, PotentialPayment.count
                assert_equal 0, @payout_report.amount
              end

              it 'recieves no emails' do
                assert_empty ActionMailer::Base.deliveries 
              end
            end
          end

        end

        describe 'without balance' do
          let(:balance_response) { [] }
          let(:should_send_notifications) { true }

          before do
            Rails.application.secrets[:fee_rate] = 0.05
            @payout_report = PayoutReport.create(fee_rate: 0.05)

            stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?").
              to_return(status: 200, body: balance_response.to_json)

            subject
          end

          it 'is not included in the payout report' do 
            assert_equal 0, PotentialPayment.count
            assert_equal 0, @payout_report.amount
          end

          it 'recieves no emails' do
            assert_empty ActionMailer::Base.deliveries 
          end
        end
      end

      describe 'without address' do
        describe 'with balance' do
          let(:balance_response) do
            [
              {
                account_id: "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
                account_type: "owner",
                balance: "20.00"
              },
              {
                account_id: "uphold_connected.org",
                account_type: "channel",
                balance: "20.00"
              },
              {
                account_id: "twitch#author:ucTw",
                account_type: "channel",
                balance: "20.00"
              },      {
                account_id: "twitter#channel:def456",
                account_type: "channel",
                balance: "20.00"
              }
            ]
          end

          before do
            Rails.application.secrets[:fee_rate] = 0.05
            @payout_report = PayoutReport.create(fee_rate: 0.05)
            account_ids = balance_response.map { |x| "account=#{x[:account_id]}" }.join("&")
            stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?#{URI.escape(account_ids)}").
              to_return(status: 200, body: balance_response.to_json)
          end

          # Technically this path would only be possible if the user was restricted
          #  eyeshade omits the wallet address if the status is not ok
          describe 'is a member' do 
            let(:wallet_response) do
              { wallet: { authorized: false, status: "restricted", "isMember": true } }
            end

            before do
              stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
                to_return(status: 200, body: wallet_response.to_json, headers: {})
            end

            describe 'should_send_notifications is true' do
              let(:should_send_notifications) { true }

              before do
                subject
              end

              it 'is not included in the report' do
                assert_equal 0, PotentialPayment.count
                assert_equal 0, @payout_report.amount
              end

              it 'recieves an email to check uphold' do
                email = ActionMailer::Base.deliveries.last
                assert_equal email&.subject, I18n.t('publisher_mailer.uphold_member_restricted.subject')
              end
            end

            describe 'should_send_notifications is false' do
              let(:should_send_notifications) { false }

              before do
                subject
              end

              it 'is not included in the report' do
                assert_equal 0, PotentialPayment.count
                assert_equal 0, @payout_report.amount
              end

              it 'does not recieve any emails' do
                assert_empty ActionMailer::Base.deliveries 
              end
            end
          end

          describe 'not a member' do
            let(:wallet_response) do
              { wallet: { authorized: false, address: "ae42daaa-69d8-4400-a0f4-d359279cd3d2", status: "restricted", "isMember": false } }
            end

            before do
              stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
                to_return(status: 200, body: wallet_response.to_json, headers: {})
            end

            describe 'should_send_notifications is true' do
              let(:should_send_notifications) { true }
              before { subject }

              it 'is not included in report' do
                assert_equal 0, PotentialPayment.count
                assert_equal 0, @payout_report.amount
              end

              it 'recieves an email to connect uphold' do
                email = ActionMailer::Base.deliveries.last
                assert_equal email&.subject, I18n.t('publisher_mailer.wallet_not_connected.subject')
              end
            end

            describe 'should_send_notifications is false' do
              let(:should_send_notifications) { false }
              before { subject }

              it 'is not included in report' do
                assert_equal 0, PotentialPayment.count
                assert_equal 0, @payout_report.amount
              end

              it 'does not receive any emails ' do
                assert_empty ActionMailer::Base.deliveries 
              end
            end

          end
        end
      end
    end
  end

  # test "publisher with verified channel that is not uphold verified is not included in the report" do
  #   Rails.application.secrets[:api_eyeshade_offline] = false

  #   payout_report = PayoutReport.create()
  #   prev_num_potential_payments = PotentialPayment.count

  #   # Clear database
  #   publisher = publishers(:youtube_initial) # has verified channel, is not uphold connected
  #   delete_publishers_except([publisher.id])

  #   # Stub /wallet reponse
  #   wallet_response = {"wallet" => {"address" => "ae42daaa-69d8-4400-a0f4-d359279cd3d2"}}.to_json

  #   stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
  #     to_return(status: 200, body: wallet_response, headers: {})

  #   # Stub /balances response
  #   balance_response = [
  #     {
  #       "account_id" => "publishers#uuid:2fcb973c-7f7c-5351-809f-0eed1de17a77",
  #       "account_type" => "owner",
  #       "balance" => "500.00"
  #     },
  #     {
  #       "account_id" => "youtube#channel:",
  #       "account_type" => "channel",
  #       "balance" => "500.00"
  #     }
  #   ].to_json

  #   stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?account=publishers%23uuid:2fcb973c-7f7c-5351-809f-0eed1de17a77&account=youtube%23channel:").
  #     to_return(status: 200, body: balance_response)

  #   perform_enqueued_jobs do
  #     PayoutReportPublisherIncluder.new(payout_report: payout_report,
  #                                       publisher: publisher,
  #                                       should_send_notifications: true).perform
  #   end

  #   email = ActionMailer::Base.deliveries.last

  #   # Ensure the correct email is sent
  #   assert_equal email.subject, I18n.t('publisher_mailer.wallet_not_connected.subject')

  #   # Ensure empty payout & payments
  #   assert_equal PotentialPayment.count, prev_num_potential_payments
  #   assert_equal payout_report.amount, 0
  # end

  # test "publisher with verified channel that is uphold verified but not a member is not included in the report" do
  #   Rails.application.secrets[:api_eyeshade_offline] = false

  #   payout_report = PayoutReport.create()
  #   prev_num_potential_payments = PotentialPayment.count

  #   # Clear database
  #   publisher = publishers(:uphold_connected) # has >1 verified channel, is uphold connected

  #   delete_publishers_except([publisher.id])

  #   # Stub /wallet reponse
  #   wallet_response = {"wallet" => {"address" => "ae42daaa-69d8-4400-a0f4-d359279cd3d2", "status": "restricted", "isMember": false}}.to_json

  #   stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
  #     to_return(status: 200, body: wallet_response, headers: {})

  #   # Stub /balances response
  #   balance_response = [
  #     {
  #       "account_id" => publisher.owner_identifier,
  #       "account_type" => "owner",
  #       "balance" => "500.00"
  #     },
  #     {
  #       "account_id" => "youtube#channel:",
  #       "account_type" => "channel",
  #       "balance" => "500.00"
  #     }
  #   ].to_json

  #   stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?account=#{URI.escape(publisher.owner_identifier)}}&account=uphold_connected.org&account=twitch%23author:ucTw&account=twitter%23channel:def456").
  #     to_return(status: 200, body: balance_response)

  #   perform_enqueued_jobs do
  #     PayoutReportPublisherIncluder.new(payout_report: payout_report,
  #                                       publisher: publisher,
  #                                       should_send_notifications: true).perform
  #   end

  #   email = ActionMailer::Base.deliveries.last

  #   # Ensure the correct email is sent
  #   assert_equal email.subject, I18n.t('publisher_mailer.uphold_kyc_incomplete.subject')

  #   # Ensure empty payout & payments
  #   assert_equal PotentialPayment.count, prev_num_potential_payments
  #   assert_equal payout_report.amount, 0
  # end

  # test "uphold verified publisher with verified channel with no address supplied is not included in the report, and is sent email" do
  #   Rails.application.secrets[:api_eyeshade_offline] = false

  #   payout_report = PayoutReport.create()
  #   prev_num_potential_payments = PotentialPayment.count

  #   # Clear database
  #   publisher = publishers(:uphold_connected) # has >1 verified channel, is uphold connected

  #   delete_publishers_except([publisher.id])

  #   # Stub disconnected /wallet response
  #   wallet_response = {}.to_json

  #   stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
  #     to_return(status: 200, body: wallet_response, headers: {})

  #   # Stub /balances response
  #   balance_response = [
  #     {
  #       "account_id" => "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
  #       "account_type" => "owner",
  #       "balance" => "20.00"
  #     },
  #     {
  #       "account_id" => "uphold_connected.org",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     },
  #     {
  #       "account_id" => "twitch#channel:ucTw",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     },      {
  #       "account_id" => "twitter#channel:def456",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     }
  #   ].to_json

  #   stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23author:ucTw&account=twitter%23channel:def456").
  #     to_return(status: 200, body: balance_response)

  #   # Deliver the email
  #   perform_enqueued_jobs do
  #     PayoutReportPublisherIncluder.new(payout_report: payout_report,
  #                                       publisher: publisher,
  #                                       should_send_notifications: true).perform
  #   end

  #   email = ActionMailer::Base.deliveries.last

  #   # Ensure the correct email is sent
  #   assert_equal email.subject, I18n.t('publisher_mailer.wallet_not_connected.subject')

  #   # Ensure payout is empty and no potential payment was created
  #   assert_equal PotentialPayment.count, prev_num_potential_payments

  #   assert_equal payout_report.num_payments, 0
  #   assert_equal payout_report.amount, 0
  # end

  # test "uphold verified publisher with verified channel with address and balance is included in payout report" do
  #   Rails.application.secrets[:api_eyeshade_offline] = false
  #   Rails.application.secrets[:fee_rate] = 0.05

  #   payout_report = PayoutReport.create(fee_rate: 0.05)

  #   # Clear database
  #   publisher = publishers(:uphold_connected) # has >1 verified channel, is uphold connected
  #   delete_publishers_except([publisher.id])

  #   # Stub disconnected /wallet response
  #   wallet_response = {"wallet" => {address: "ae42daaa-69d8-4400-a0f4-d359279cd3d2", status: "ok", isMember: true}}.to_json

  #   stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
  #     to_return(status: 200, body: wallet_response, headers: {})

  #   # Stub /balances response
  #   balance_response = [
  #     {
  #       "account_id" => "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
  #       "account_type" => "owner",
  #       "balance" => "20.00"
  #     },
  #     {
  #       "account_id" => "uphold_connected.org",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     },
  #     {
  #       "account_id" => "twitch#author:ucTw",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     },      {
  #       "account_id" => "twitter#channel:def456",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     }
  #   ].to_json

  #   stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23author:ucTw&account=twitter%23channel:def456").
  #     to_return(status: 200, body: balance_response)

  #   # Ensure no emails sent
  #   assert_enqueued_jobs(1) do
  #     PayoutReportPublisherIncluder.new(payout_report: payout_report,
  #                                       publisher: publisher,
  #                                       should_send_notifications: true).perform
  #   end

  #   # Ensure data is correct
  #   assert_equal payout_report.num_payments, publisher.channels.count + 1
  #   assert_equal payout_report.amount, (80 * BigDecimal('1e18') - ((60 * BigDecimal.new('1e18')) * payout_report.fee_rate)).to_i
  #   assert_equal payout_report.fees, (60 * BigDecimal('1e18') * payout_report.fee_rate).to_i

  #   # Ensure individual potential payment data is correct
  #   PotentialPayment.where(payout_report_id: payout_report.id).each do |potential_payment|
  #     assert_equal potential_payment.address, JSON.parse(wallet_response)["wallet"]["address"]
  #     assert_equal potential_payment.publisher_id, "#{publisher.id}"
  #     if potential_payment.kind == PotentialPayment::CONTRIBUTION
  #       assert_equal potential_payment.amount, (20 * BigDecimal('1e18') - ((20 * BigDecimal.new('1e18')) * payout_report.fee_rate)).to_i.to_s
  #     elsif potential_payment.kind == PotentialPayment::REFERRAL
  #       assert_equal potential_payment.amount, (20 * BigDecimal('1e18')).to_i.to_s
  #     end
  #   end

  #   # Run the includer again with same parameters and ensure no extra potential payments
  #   # were created (idempotence)

  #   assert_difference -> { PotentialPayment.count }, 0 do
  #     PayoutReportPublisherIncluder.new(payout_report: payout_report,
  #                                       publisher: publisher,
  #                                       should_send_notifications: true).perform
  #   end
  # end

  # test "publisher with only a contribution balance but no wallet address receives an email" do
  #   Rails.application.secrets[:api_eyeshade_offline] = false
  #   Rails.application.secrets[:fee_rate] = 0.05

  #   payout_report = PayoutReport.create(fee_rate: 0.05)

  #   # Clear database
  #   publisher = publishers(:uphold_connected) # has >1 verified channel, is uphold connected
  #   delete_publishers_except([publisher.id])

  #   # Stub disconnected /wallet response
  #   wallet_response = {"wallet" => {"address" => ""}}.to_json

  #   stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
  #     to_return(status: 200, body: wallet_response, headers: {})

  #   # Stub /balances response
  #   balance_response = [
  #     {
  #       "account_id" => "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
  #       "account_type" => "owner",
  #       "balance" => "0.00"
  #     },
  #     {
  #       "account_id" => "uphold_connected.org",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     },
  #     {
  #       "account_id" => "twitch#author:ucTw",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     },      {
  #       "account_id" => "twitter#channel:def456",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     }
  #   ].to_json

  #   stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23author:ucTw&account=twitter%23channel:def456").
  #     to_return(status: 200, body: balance_response)

  #   # Ensure is emails sent
  #   assert_enqueued_jobs(2) do
  #     PayoutReportPublisherIncluder.new(payout_report: payout_report,
  #                                       publisher: publisher,
  #                                       should_send_notifications: true).perform
  #   end
  # end

  # test "only sends notifications if payout_id is false" do
  #   Rails.application.secrets[:api_eyeshade_offline] = false
  #   Rails.application.secrets[:fee_rate] = 0.05

  #   payout_report = PayoutReport.create(fee_rate: 0.05)

  #   # Clear database
  #   publisher = publishers(:uphold_connected) # has >1 verified channel, is uphold connected
  #   delete_publishers_except([publisher.id])

  #   # Stub disconnected /wallet response
  #   wallet_response = {"wallet" => {"address" => "ae42daaa-69d8-4400-a0f4-d359279cd3d2", status: "restricted", "isMember": false}}.to_json

  #   stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
  #     to_return(status: 200, body: wallet_response, headers: {})

  #   # Stub /balances response
  #   balance_response = [
  #     {
  #       "account_id" => "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
  #       "account_type" => "owner",
  #       "balance" => "0.00"
  #     },
  #     {
  #       "account_id" => "uphold_connected.org",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     },
  #     {
  #       "account_id" => "twitch#author:ucTw",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     },      {
  #       "account_id" => "twitter#channel:def456",
  #       "account_type" => "channel",
  #       "balance" => "20.00"
  #     }
  #   ].to_json

  #   stub_request(:get, "#{api_eyeshade_base_uri}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23author:ucTw&account=twitter%23channel:def456").
  #     to_return(status: 200, body: balance_response)

  #   # Ensure is emails sent
  #   assert_difference -> { PotentialPayment.count }, 0 do
  #     assert_enqueued_jobs(2) do
  #       PayoutReportPublisherIncluder.new(payout_report: nil,
  #                                         publisher: publisher,
  #                                         should_send_notifications: true).perform
  #     end
  #   end
  # end
end
