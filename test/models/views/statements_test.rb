require "test_helper"

class StatementsTest < ActiveSupport::TestCase
  let(:subject) { Views::User::Statements.new(publisher: publishers(:default)).as_json[:overviews] }

  describe "when there are no statements" do
    it "has no overviews" do
      expect(subject).must_equal([])
    end
  end

  describe "when there are eyeshade contribution statements" do
    let(:total_earned) { 94986.42173631497819143 }
    let(:total_fees) { -4749.321086815748909571 }
    let(:total_bat_deposited) { 90237.100649499229281859 }

    let(:statements) do
      [
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          description: "contributions through Oct",
          transaction_type: "contribution",
          amount: 94986.42173631497819143,
          created_at: "2019-10-09".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          description: "settlement fees",
          transaction_type: "fees",
          amount: -4749.321086815748909571,
          created_at: "2019-10-09".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          description: "payout for contribution",
          transaction_type: "contribution_settlement",
          amount: -90237.100649499229281859,
          settlement_currency: "USD",
          settlement_amount: 17903.78,
          settlement_destination_type: "uphold",
          settlement_destination: "69d842d3-c8f8-438f-969b-36c3d6e3e182",
          created_at: "2019-10-09".to_date,
        ),
      ]
    end

    before do
      @statement_mock = MiniTest::Mock.new
      @statement_mock.expect(:perform, statements)
    end

    it 'has the correct date range' do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.earning_period).must_equal('Sep 2019 - Oct 2019')
      end
    end

    it "correctly calculates the total earned" do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.total_earned).must_equal(total_earned)
      end
    end

    it "correctly calculates the total fees" do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.total_fees).must_equal(total_fees)
      end
    end

    it "correctly calculates the total BAT deposited" do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.total_bat_deposited).must_equal(total_bat_deposited)
      end
    end
  end

  describe "when there are eyeshade and uphold contribution statements" do
    let(:total_earned) { 95196.37173631498 }
    let(:total_fees) { -4749.321086815748909571 }
    let(:total_bat_deposited) { 90447.05064949923 }

    let(:statements) do
      [
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          description: "contributions through Oct",
          transaction_type: "contribution",
          amount: 94986.42173631497819143,
          created_at: "2019-10-09".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          description: "settlement fees",
          transaction_type: "fees",
          amount: -4749.321086815748909571,
          created_at: "2019-10-09".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          description: "payout for contribution",
          transaction_type: "contribution_settlement",
          amount: -90237.100649499229281859,
          settlement_currency: "USD",
          settlement_amount: 17903.78,
          settlement_destination_type: "uphold",
          settlement_destination: "69d842d3-c8f8-438f-969b-36c3d6e3e182",
          created_at: "2019-10-09".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.19,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 0.97,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.97,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.97,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.97,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.96,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.97,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.97,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.97,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.97,
          created_at: "2019-9-14".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.2,
          created_at: "2019-9-15".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 0.98,
          created_at: "2019-9-15".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.19,
          created_at: "2019-9-16".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 1.0,
          created_at: "2019-9-16".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 2.85,
          settlement_currency: "USD",
          settlement_amount: 0.59,
          created_at: "2019-9-16".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 0.98,
          created_at: "2019-9-16".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.89,
          created_at: "2019-9-16".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.18,
          created_at: "2019-9-16".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 0.94,
          created_at: "2019-9-16".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 1.9,
          created_at: "2019-9-16".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.2,
          created_at: "2019-9-17".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 1.05,
          created_at: "2019-9-17".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 2.11,
          created_at: "2019-9-17".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 1.05,
          created_at: "2019-9-17".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.2,
          created_at: "2019-9-17".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 3.8,
          settlement_currency: "USD",
          settlement_amount: 0.81,
          created_at: "2019-9-18".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.19,
          created_at: "2019-9-18".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.2,
          created_at: "2019-9-18".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 1.01,
          created_at: "2019-9-18".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.2,
          created_at: "2019-9-18".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.19,
          created_at: "2019-9-19".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.19,
          created_at: "2019-9-19".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.19,
          created_at: "2019-9-20".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.18,
          created_at: "2019-9-20".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.18,
          created_at: "2019-9-20".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.18,
          created_at: "2019-9-20".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.18,
          created_at: "2019-9-20".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.18,
          created_at: "2019-9-20".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 8.55,
          settlement_currency: "USD",
          settlement_amount: 1.81,
          created_at: "2019-9-21".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 8.55,
          settlement_currency: "USD",
          settlement_amount: 1.81,
          created_at: "2019-9-21".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.19,
          created_at: "2019-9-21".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.21,
          created_at: "2019-9-22".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.21,
          created_at: "2019-9-22".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.2,
          created_at: "2019-9-22".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 1.13,
          created_at: "2019-9-23".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.22,
          created_at: "2019-9-23".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 4.75,
          settlement_currency: "USD",
          settlement_amount: 1.1,
          created_at: "2019-9-23".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 2.85,
          settlement_currency: "USD",
          settlement_amount: 0.65,
          created_at: "2019-9-23".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 0.95,
          settlement_currency: "USD",
          settlement_amount: 0.21,
          created_at: "2019-9-23".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution",
          amount: 9.5,
          settlement_currency: "USD",
          settlement_amount: 2.15,
          created_at: "2019-9-23".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          transaction_type: "uphold_contribution_settlement",
          amount: -209.95,
          settlement_currency: "BAT",
          settlement_amount: 209.95,
          created_at: "2019-9-29".to_date,
        ),
      ]
    end

    before do
      @statement_mock = MiniTest::Mock.new
      @statement_mock.expect(:perform, statements)
    end

    it 'has the correct date range' do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.earning_period).must_equal('Sep 2019 - Oct 2019')
      end
    end

    it "correctly calculates the total earned" do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.total_earned).must_equal(total_earned)
      end
    end

    it "correctly calculates the total fees" do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.total_fees).must_equal(total_fees)
      end
    end

    it "correctly calculates the total BAT deposited" do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.total_bat_deposited).must_equal(total_bat_deposited)
      end
    end
  end

  describe "when there are eyeshade and uphold contribution statements" do
    let(:total_earned) { 48.679371409300686 }
    let(:total_fees) { -1.0 }
    let(:total_bat_deposited) { 47.679371409300686 }

    let(:statements) do
      [
        PublisherStatementGetter::Statement.new(
          channel: "Publisher Account",
          description: "payout for referral",
          transaction_type: "referral_settlement",
          amount: -28.679371409300689187,
          settlement_currency: "USD",
          settlement_amount: 8.19,
          settlement_destination_type: "uphold",
          settlement_destination: "",
          created_at: "2019-04-09".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          description: "contributions through Apr",
          transaction_type: "contribution",
          amount: 20.0,
          created_at: "2019-04-09".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          description: "settlement fees",
          transaction_type: "fees",
          amount: -1.0,
          created_at: "2019-04-09".to_date,
        ),
        PublisherStatementGetter::Statement.new(
          channel: "website.com",
          description: "payout for contribution",
          transaction_type: "contribution_settlement",
          amount: -19.0,
          settlement_currency: "USD",
          settlement_amount: 5.34,
          settlement_destination_type: "uphold",
          settlement_destination: "",
          created_at: "2019-04-09".to_date,
        ),
      ]
    end

    before do
      @statement_mock = MiniTest::Mock.new
      @statement_mock.expect(:perform, statements)
    end

    it 'has the correct date range' do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.earning_period).must_equal('Mar 2019 - Apr 2019')
      end
    end

    it "correctly calculates the total earned" do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.total_earned).must_equal(total_earned)
      end
    end

    it "correctly calculates the total fees" do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.total_fees).must_equal(total_fees)
      end
    end

    it "correctly calculates the total BAT deposited" do
      PublisherStatementGetter.stub(:new, @statement_mock) do
        expect(subject.first.total_bat_deposited).must_equal(total_bat_deposited)
      end
    end
  end
end
