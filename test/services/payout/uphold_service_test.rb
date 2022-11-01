# typed: false

require "test_helper"

class UpholdServiceTest < ActiveJob::TestCase
  before do
    PotentialPayment.destroy_all
    @prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    @prev_fee_rate = Rails.application.secrets[:fee_rate]
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_offline
    Rails.application.secrets[:fee_rate] = @prev_fee_rate
  end

  describe "when publisher does not have a verified channel" do
    let(:publisher) { publishers(:fake1) }

    let(:subject) do
      @results = Payout::UpholdService.new
        .perform(
          payout_report:
            PayoutReport.create(
              expected_num_payments:
                PayoutReport.expected_num_payments(Publisher.all)
            ),
          publisher: publisher
        )
    end

    before { subject }

    it "does not generate a report" do
      assert_equal publisher.channels.verified.count, @results.length
    end
  end

  describe "when publisher is suspended" do
    let(:publisher) { publishers(:suspended) }

    let(:subject) do
      @results = Payout::UpholdService.new
        .perform(
          payout_report: PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments(Publisher.all)),
          publisher: publisher
        )
    end

    before { subject }

    it "does generate a report noting publisher is suspended" do
      assert_equal publisher.channels.verified.count, @results.length
      @results.each { |pp| assert_equal "suspended", pp.status }
    end
  end

  describe "when a user needs to reauthorize brave on uphold" do
    let(:publisher) { publishers(:uphold_connected_reauthorize) }

    let(:subject) do
      @results = Payout::UpholdService.new
        .perform(
          payout_report: @payout_report,
          publisher: publisher
        )
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
      @payout_report = PayoutReport.create(fee_rate: 0.05, expected_num_payments: PayoutReport.expected_num_payments(Publisher.all))
      subject
    end

    it "creates potential payments" do
      assert_equal publisher.channels.verified.count, @results.length
    end

    it "records reauthorizatio was needed for potential payments" do
      @results.each do |potential_payment|
        assert potential_payment.reauthorization_needed
      end
    end
  end

  describe "when user is blocked from uphold" do
    let(:publisher) { publishers(:uphold_connected_blocked) }

    let(:subject) do
      @results = Payout::UpholdService.new.perform(payout_report: @payout_report,
        publisher: publisher)
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

      subject
    end

    it "creates 4 potential payments" do
      assert_equal publisher.channels.verified.count, @results.length
      @results.each do |potential_payment|
        refute potential_payment.suspended
        refute potential_payment.reauthorization_needed
        assert_equal "blocked", potential_payment.uphold_status
        if potential_payment.kind == PotentialPayment::REFERRAL
          assert_equal "0", potential_payment.fees
          assert_equal "uphold", potential_payment.wallet_provider # uphold enum
        elsif potential_payment.kind == PotentialPayment::CONTRIBUTION
          assert_equal "0", potential_payment.fees
          assert_equal "uphold", potential_payment.wallet_provider # uphold enum
        end
      end
    end
  end

  describe "publisher has a verified channel" do
    before do
      Rails.application.secrets[:api_eyeshade_offline] = false
    end

    describe "when not uphold verified" do
      let(:publisher) { publishers(:youtube_initial) }

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
        @results = Payout::UpholdService.new.perform(payout_report: PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments(Publisher.all)),
          publisher: publisher)
      end

      before do
        Rails.application.secrets[:api_eyeshade_offline] = false
        subject
      end

      it "creates two potential payments" do
        assert_equal publisher.channels.verified.count, @results.length

        @results.each do |potential_payment|
          refute potential_payment.reauthorization_needed
          refute potential_payment.uphold_member
          refute potential_payment.suspended
          assert_nil potential_payment.uphold_status
        end
      end
    end

    describe "when in a suspended country" do
      let(:publisher) { publishers(:youtube_initial) }
      it "does generate a potential payment" do
        payout_message_count = PayoutMessage.count
        result = Payout::UpholdService.new.perform(payout_report: PayoutReport.last, publisher: publisher, allowed_regions: ['US'])
        assert result[0].publisher_id == publisher.id
        assert PayoutMessage.count == payout_message_count
      end

      it "does not generate a potential payment" do
        payout_message_count = PayoutMessage.count
        result = Payout::UpholdService.new.perform(payout_report: PayoutReport.last, publisher: publisher, allowed_regions: ['CN'])
        assert result == []
        assert PayoutMessage.count == payout_message_count + 1
        assert PayoutMessage.last.message =~ /unallowed/
      end
    end
  end

  describe "when uphold verified" do
    let(:subject) do
      @results = Payout::UpholdService.new.perform(payout_report: @payout_report,
        publisher: publisher)
    end

    # All members should have addresses
    describe "with address" do
      describe "with balance" do
        let(:balance_response) do
          [
            {account_id: "publishers#uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8", account_type: "owner", balance: "20.00"},
            {account_id: publishers(:promo_not_registered).owner_identifier, account_type: "owner", balance: "20.00"},
            {account_id: publishers(:promo_lockout).owner_identifier, account_type: "owner", balance: "20.00"},
            {account_id: "uphold_connected_details.org", account_type: "channel", balance: "20.00"},
            {account_id: "twitch#author:details", account_type: "channel", balance: "20.00"},
            {account_id: "twitter#channel:details", account_type: "channel", balance: "20.00"},
            {account_id: channels(:reddit_promo_registered).details.channel_identifier, account_type: "channel", balance: "20.00"}
          ]
        end

        before do
          Rails.application.secrets[:fee_rate] = 0.05
          @payout_report = PayoutReport.create(fee_rate: 0.05, expected_num_payments: PayoutReport.expected_num_payments(Publisher.all))
        end

        describe "when is a member" do
          let(:publisher) { publishers(:uphold_connected_details) }

          describe "when payout_report exists" do
            before do
              Rails.application.secrets[:api_eyeshade_offline] = false
              subject
            end

            it "is included in payout report" do
              assert_equal @results.length, publisher.channels.count
              assert_equal @results.length, 3
              assert @results.all? { |result| result.payout_report_id == @payout_report.id }
            end

            it "has the correct content" do
              @results.each do |potential_payment|
                assert_equal potential_payment.address, publisher.uphold_connection.address
                assert_equal potential_payment.publisher_id, publisher.id.to_s
                assert_equal publisher.uphold_connection.uphold_id, potential_payment.uphold_id

                if potential_payment.kind == PotentialPayment::CONTRIBUTION
                  assert potential_payment.channel_stats.present?
                  assert potential_payment.channel_type.present?
                  assert_equal potential_payment.channel.details.stats, potential_payment.channel_stats
                  assert_equal potential_payment.channel.details_type, potential_payment.channel_type
                end
                assert_equal "ok", potential_payment.uphold_status
                assert potential_payment.uphold_member
                refute potential_payment.suspended
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
          let(:publisher) { publishers(:uphold_connected_details) }

          before do
            Rails.application.secrets[:fee_rate] = 0.05
            @payout_report = PayoutReport.create(fee_rate: 0.05, expected_num_payments: PayoutReport.expected_num_payments(Publisher.all))
            subject
          end

          it "is not included in the payout report" do
            assert_equal publisher.channels.verified.count, @results.length
            assert_equal 0, @payout_report.amount
          end
        end
      end
    end
  end
end
