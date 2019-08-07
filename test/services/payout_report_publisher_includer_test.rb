require "test_helper"
require "webmock/minitest"

class PayoutReportPublisherIncluderTest < ActiveJob::TestCase
  include EyeshadeHelper
  let(:uphold_url) { Rails.application.secrets[:uphold_api_uri] + "/v0/me" }

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

  describe "when publisher does not have a verified channel" do
    let(:publisher) { publishers(:fake1) }

    let(:subject) do
      perform_enqueued_jobs do
        PayoutReportPublisherIncluder.new(payout_report: PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments(Publisher.all)),
                                          publisher: publisher,
                                          should_send_notifications: true).perform
      end
    end

    before { subject }

    it "does not generate a report" do
      assert_equal 0, PotentialPayment.count
    end
  end

  describe "when publisher is suspended" do
    let(:publisher) { publishers(:suspended) }

    let(:subject) do
      perform_enqueued_jobs do
        PayoutReportPublisherIncluder.new(payout_report: PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments(Publisher.all)),
                                          publisher: publisher,
                                          should_send_notifications: true).perform
      end
    end

    before { subject }

    it "does generate a report noting publisher is suspended" do
      assert_equal 2, PotentialPayment.count
      PotentialPayment.all.each { |pp| assert_equal "suspended", pp.status }
    end
  end

  describe "when a user needs to reauthorize brave on uphold" do
    let(:publisher) { publishers(:uphold_connected_reauthorize) }

    let (:subject) do
      perform_enqueued_jobs do
        PayoutReportPublisherIncluder.new(payout_report: @payout_report,
                                          publisher: publisher,
                                          should_send_notifications: false).perform
      end
    end

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
        }, {
          account_id: "twitter#channel:def456",
          account_type: "channel",
          balance: "20.00"
        }
      ]
    end

    before do
      Rails.application.secrets[:fee_rate] = 0.05
      Rails.application.secrets[:api_eyeshade_offline] = false
      @payout_report = PayoutReport.create(fee_rate: 0.05, expected_num_payments: PayoutReport.expected_num_payments(Publisher.all))
      stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
      stub_request(:get, uphold_url).to_return(body: {}.to_json)

      subject
    end

   it "creates the potential payments" do
      assert_equal 4, PotentialPayment.count
    end

    it "does not include them in payout report" do
      @payout_report.update_report_contents
      assert_equal 0, JSON.parse(@payout_report.contents).length
    end

    it "records reauthorizatio was needed for potential payments" do
      PotentialPayment.all.each do |potential_payment|
        assert potential_payment.reauthorization_needed
      end
    end
  end

  describe "when user is blocked from uphold" do
    let(:publisher) { publishers(:uphold_connected_blocked) }

    let(:subject) do
      perform_enqueued_jobs do
        PayoutReportPublisherIncluder.new(payout_report: @payout_report,
                                          publisher: publisher,
                                          should_send_notifications: false).perform
      end
    end

    let(:balance_response) do
      [
        {
          account_id: "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
          account_type: "owner",
          balance: "20.00"
        },
        {
          account_id: "uphold_connected_blocked.org",
          account_type: "channel",
          balance: "20.00"
        },
        {
          account_id: "twitch#author:blocked",
          account_type: "channel",
          balance: "20.00"
        }, {
          account_id: "twitter#channel:blocked",
          account_type: "channel",
          balance: "20.00"
        }
      ]
    end

    before do
      Rails.application.secrets[:fee_rate] = 0.05
      Rails.application.secrets[:api_eyeshade_offline] = false
      @payout_report = PayoutReport.create(fee_rate: 0.05, expected_num_payments: PayoutReport.expected_num_payments(Publisher.all))

      stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
      stub_request(:get, uphold_url).to_return(body: { status: "blocked", memberAt: "2019" }.to_json)

      subject
    end

    it "creates 4 potential payments" do
      assert_equal 4, PotentialPayment.count
      PotentialPayment.all.each do |potential_payment|
        refute potential_payment.suspended
        refute potential_payment.reauthorization_needed
        assert_equal "blocked", potential_payment.uphold_status
        if potential_payment.kind == PotentialPayment::REFERRAL
          assert_equal "20000000000000000000", potential_payment.amount
          assert_equal "0", potential_payment.fees
        elsif potential_payment.kind == PotentialPayment::CONTRIBUTION
          assert_equal "19000000000000000000", potential_payment.amount
          assert_equal  "1000000000000000000", potential_payment.fees
        end
      end
    end

    it "does not include any in payout report" do
      @payout_report.update_report_contents
      assert_equal 0, JSON.parse(@payout_report.contents).length
    end
  end

  describe "publisher has a verified channel" do
    before do
      Rails.application.secrets[:api_eyeshade_offline] = false
    end

    describe "when not uphold verified" do
      let(:publisher) { publishers(:youtube_initial) }
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
          PayoutReportPublisherIncluder.new(payout_report: PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments(Publisher.all)),
                                            publisher: publisher,
                                            should_send_notifications: should_send_notifications).perform
        end
      end

      before do
        Rails.application.secrets[:api_eyeshade_offline] = false
        stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
        stub_request(:get, uphold_url).to_return(body: { }.to_json)

        subject
      end

      it "creates two potential payments" do
        assert_equal 2, PotentialPayment.count

        PotentialPayment.all.each do |potential_payment|
          refute potential_payment.reauthorization_needed
          refute potential_payment.uphold_member
          refute potential_payment.suspended
          assert_nil potential_payment.uphold_status
        end
      end

      it "doesn't include any in payout report" do
        payout_report = PayoutReport.order("created_at").last
        payout_report.update_report_contents
        assert_equal 0, JSON.parse(payout_report.contents).length
      end

      it "sends email to connect uphold" do
        email = ActionMailer::Base.deliveries.last
        assert_equal email&.subject, I18n.t("publisher_mailer.wallet_not_connected.subject")
      end
    end
  end

  describe "when uphold verified" do
    let(:should_send_notifications) { true }
    let(:subject) do
      perform_enqueued_jobs do
        PayoutReportPublisherIncluder.new(payout_report: @payout_report,
                                          publisher: publisher,
                                          should_send_notifications: should_send_notifications).perform
      end
    end

    # All members should have addresses
    describe "with address" do
      describe "with balance" do
        let(:balance_response) do
          [
            {
              account_id: "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
              account_type: "owner",
              balance: "20.00"
            },
            {
              account_id: "uphold_connected_details.org",
              account_type: "channel",
              balance: "20.00"
            },
            {
              account_id: "twitch#author:details",
              account_type: "channel",
              balance: "20.00"
            }, {
              account_id: "twitter#channel:details",
              account_type: "channel",
              balance: "20.00"
            }
          ]
        end

        before do
          Rails.application.secrets[:fee_rate] = 0.05
          @payout_report = PayoutReport.create(fee_rate: 0.05, expected_num_payments: PayoutReport.expected_num_payments(Publisher.all))
          stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
          stub_request(:get, uphold_url).to_return(body: { status: "ok", memberAt: "2019" }.to_json)
        end

        describe "when is a member" do
          let(:publisher) { publishers(:uphold_connected_details) }

          describe "when should_send_notifications is false" do
            let(:should_send_notifications) { false }

            describe "when payout_report exists" do
              before do
                Rails.application.secrets[:api_eyeshade_offline] = false
                stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
                stub_request(:get, uphold_url).to_return(body: { status: "ok", memberAt: "2019", id: "123e4567-e89b-12d3-a456-426655440000" }.to_json)
                subject
              end

              it "is included in payout report" do
                assert_equal @payout_report.num_payments, publisher.channels.count + 1
                assert_equal @payout_report.amount, (80 * BigDecimal("1e18") - ((60 * BigDecimal("1e18")) * @payout_report.fee_rate)).to_i
                assert_equal @payout_report.fees, (60 * BigDecimal("1e18") * @payout_report.fee_rate).to_i

                @payout_report.update_report_contents
                assert_equal 4, JSON.parse(@payout_report.contents).length
              end

              it "has the correct content" do
                PotentialPayment.where(payout_report_id: @payout_report.id).each do |potential_payment|
                  assert_equal potential_payment.address, publisher.uphold_connection.address
                  assert_equal potential_payment.publisher_id, publisher.id.to_s
                  assert_equal publisher.uphold_connection.uphold_id, potential_payment.uphold_id

                  if potential_payment.kind == PotentialPayment::CONTRIBUTION
                    assert_equal potential_payment.amount, (20 * BigDecimal("1e18") - ((20 * BigDecimal("1e18")) * @payout_report.fee_rate)).to_i.to_s
                    assert potential_payment.channel_stats.present?
                    assert potential_payment.channel_type.present?
                    assert_equal potential_payment.channel.details.stats, potential_payment.channel_stats
                    assert_equal potential_payment.channel.details_type, potential_payment.channel_type
                  elsif potential_payment.kind == PotentialPayment::REFERRAL
                    assert_equal potential_payment.amount, (20 * BigDecimal("1e18")).to_i.to_s
                  end
                  assert_equal "ok", potential_payment.uphold_status
                  assert potential_payment.uphold_member
                  refute potential_payment.suspended
                end
              end

              it "does not create any extra payments" do
                assert_difference -> { PotentialPayment.count }, 0 do
                  PayoutReportPublisherIncluder.new(payout_report: @payout_report,
                                                    publisher: publisher,
                                                    should_send_notifications: should_send_notifications).perform
                end
              end

              it "sends no emails" do
                assert_empty ActionMailer::Base.deliveries
              end
            end
          end

          describe "when should_send_notifications is true" do
            let(:should_send_notifications) { true }

            before do
              Rails.application.secrets[:api_eyeshade_offline] = false
              stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
              subject
            end

            # This is the happy path, the publisher is in the happy state and does not need any additional contact.
            it "sends no emails" do
              assert_empty ActionMailer::Base.deliveries
            end

            it "is not included in payout report" do
              assert_equal @payout_report.num_payments, publisher.channels.count + 1
              assert_equal @payout_report.amount, (80 * BigDecimal("1e18") - ((60 * BigDecimal("1e18")) * @payout_report.fee_rate)).to_i
              assert_equal @payout_report.fees, (60 * BigDecimal("1e18") * @payout_report.fee_rate).to_i
            end

            it "has the correct content" do
              PotentialPayment.where(payout_report_id: @payout_report.id).each do |potential_payment|
                assert_equal potential_payment.address, publisher.uphold_connection.address
                assert_equal potential_payment.publisher_id, publisher.id.to_s
                if potential_payment.kind == PotentialPayment::CONTRIBUTION
                  assert_equal potential_payment.amount, (20 * BigDecimal("1e18") - ((20 * BigDecimal("1e18")) * @payout_report.fee_rate)).to_i.to_s
                elsif potential_payment.kind == PotentialPayment::REFERRAL
                  assert_equal potential_payment.amount, (20 * BigDecimal("1e18")).to_i.to_s
                end
              end
            end

            it "does not create any extra payments" do
              assert_difference -> { PotentialPayment.count }, 0 do
                PayoutReportPublisherIncluder.new(payout_report: @payout_report,
                                                  publisher: publisher,
                                                  should_send_notifications: should_send_notifications).perform
              end
            end
          end
        end


      describe "without balance" do
        let(:balance_response) do
            [
              {
                account_id: "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
                account_type: "owner",
                balance: "0.00"
              },
              {
                account_id: "uphold_connected_details.org",
                account_type: "channel",
                balance: "0.00"
              },
              {
                account_id: "twitch#author:ucTw",
                account_type: "channel",
                balance: "0.00"
              }, {
                account_id: "twitter#channel:def456",
                account_type: "channel",
                balance: "0.00"
              }
            ]
          end
        let(:should_send_notifications) { true }
        let(:publisher) { publishers(:uphold_connected_details) }

        before do
          Rails.application.secrets[:fee_rate] = 0.05
          Rails.application.secrets[:api_eyeshade_offline] = false
          @payout_report = PayoutReport.create(fee_rate: 0.05, expected_num_payments: PayoutReport.expected_num_payments(Publisher.all))
          stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
          subject
        end

        it "is not included in the payout report" do
          assert_equal 4, PotentialPayment.count
          assert_equal 0, @payout_report.amount
        end

        it "recieves no emails" do
          assert_empty ActionMailer::Base.deliveries
        end
      end
    end

    describe "without address" do
      describe "with balance" do
        let(:balance_response) do
          [
            {
              account_id: "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8",
              account_type: "owner",
              balance: "20.00"
            },
            {
              account_id: "uphold_connected_details.org",
              account_type: "channel",
              balance: "20.00"
            },
            {
              account_id: "twitch#author:restricted_member",
              account_type: "channel",
              balance: "20.00"
            }, {
              account_id: "twitter#channel:restrcted_member",
              account_type: "channel",
              balance: "20.00"
            }
          ]
        end

        before do
          Rails.application.secrets[:fee_rate] = 0.05
          Rails.application.secrets[:api_eyeshade_offline] = false
          @payout_report = PayoutReport.create(fee_rate: 0.05, expected_num_payments: PayoutReport.expected_num_payments(Publisher.all))
          stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
        end

        # Technically this path would only be possible if the user was restricted
        #  eyeshade omits the wallet address if the status is not ok
        describe "is a member and restricted" do
          let(:publisher) { publishers(:uphold_connected_restricted_member) }

          before do
            stub_all_eyeshade_wallet_responses(publisher: publisher, balances: balance_response)
            stub_request(:get, uphold_url).to_return(body: { status: "restricted", memberAt: "2019" }.to_json)
          end

          describe "should_send_notifications is true" do
            let(:should_send_notifications) { true }

            before do
              subject
            end

            it "it creates potential payments" do
              assert_equal 4, PotentialPayment.count
              assert_equal 0, @payout_report.amount
            end

            it "does not include them in payout report json" do
              @payout_report.update_report_contents
              assert_equal 0, JSON.parse(@payout_report.contents).length
            end

            it "receives an email to check uphold" do
              email = ActionMailer::Base.deliveries.last
              assert_equal email&.subject, I18n.t("publisher_mailer.uphold_member_restricted.subject")
            end
          end

          describe "should_send_notifications is false" do
            let(:should_send_notifications) { false }

            before do
              subject
            end

            it "creates payments" do
              assert_equal 4, PotentialPayment.count
              assert_equal 0, @payout_report.amount
            end

            it "does not recieve any emails" do
              assert_empty ActionMailer::Base.deliveries
            end
          end
        end


        # describe "not a member" do
        #   let(:wallet_response) do
        #     { wallet: { authorized: false, status: "restricted", "isMember": false } }
        #   end

        #   before do
        #     Rails.application.secrets[:api_eyeshade_offline] = false
        #     stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet_response, balances: balance_response)
        #     subject
        #   end

        #   describe "should_send_notifications is true" do
        #     let(:should_send_notifications) { true }

        #     it "creates the potential payments" do
        #       assert_equal 4, PotentialPayment.count
        #       assert_equal 0, @payout_report.amount
        #     end

        #     it "does not include them in payout report json" do
        #       @payout_report.update_report_contents

        #       assert_equal 0, JSON.parse(@payout_report.contents).length
        #     end

        #     it "recieves an email to KYC uphold" do
        #       email = ActionMailer::Base.deliveries.last
        #       assert_equal email&.subject, I18n.t("publisher_mailer.uphold_kyc_incomplete.subject")
        #     end
        #   end

        #   describe "should_send_notifications is false" do
        #     let(:should_send_notifications) { false }
        #     it "creates the potential payments" do
        #       assert_equal 4, PotentialPayment.count
        #       assert_equal 0, @payout_report.amount
        #     end

        #     it "does not include the payments in the payout json" do
        #       @payout_report.update_report_contents
        #       assert_equal 0, JSON.parse(@payout_report.contents).length
        #     end

        #     it "does not receive any emails " do
        #       assert_empty ActionMailer::Base.deliveries
        #     end
        #   end
        end
      end
    end
  end
end
