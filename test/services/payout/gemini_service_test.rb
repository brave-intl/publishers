require "test_helper"

class GeminiServiceTest < ActiveJob::TestCase
  let(:payout_report) { PayoutReport.create(expected_num_payments: PayoutReport.expected_num_payments(Publisher.all)) }

  let(:subject) do
    @results = Payout::GeminiService.new.perform(
      payout_report: payout_report,
      publisher: publisher,
    )
  end

  describe "when publisher does not have a verified channel" do
    let(:publisher) { publishers(:fake1) }
    before { subject }

    it "does not generate a report" do
      assert_equal 0, @results.count
    end
  end

  describe "when publisher is suspended" do
    let(:publisher) { publishers(:gemini_suspended) }

    before { subject }

    it 'marks the potential payment as suspended' do
      @results.each { |pp| assert_equal "suspended", pp.status }
    end
  end

  describe 'when a gemini connection is not verified' do
    let(:publisher) { publishers(:gemini_not_completed) }

    before do
      subject
    end

    it 'creates potential payments for the right publisher' do
      refute_equal @results.length, 0
      @results.each { |pp| assert_equal publisher.id, pp.publisher_id }
    end

    it 'has all payments marked as not verified' do
      refute @results.any? { |pp| pp.gemini_is_verified }
    end

    it 'the address is empty' do
      refute @results.any? { |pp| pp.address.present? }
    end
  end
end
