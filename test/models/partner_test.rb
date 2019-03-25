require "test_helper"

class PartnerTest < ActiveSupport::TestCase
  test "All partners will have role of Partner" do
    p = Partner.new(email: 'test@example.com')
    assert p.partner?
  end

  describe 'when balance is called' do
    let(:partner) { partners(:default_partner) }

    describe 'when there are 2 invoices in progress' do
      before do
        Invoice.destroy_all
        Invoice.create(partner: partner, date: "2019-01-01", status: "in progress", amount: 20)
        Invoice.create(partner: partner, date: "2019-02-01", status: "in progress", amount: 20)
      end

      it 'adds the total amount of invoices' do
        expect(partner.balance).must_equal 40
      end
    end

    describe 'when there is 1 invoice in progress' do
      before do
        Invoice.destroy_all
        Invoice.create(partner: partner, date: "2019-01-01", status: "in progress", amount: 20)
      end

      it 'shows only the amount of the invoice' do
        expect(partner.balance).must_equal 20
      end
    end

    describe 'when there is 1 invoice in progress and 1 paid' do
      before do
        Invoice.destroy_all
        Invoice.create(partner: partner, date: "2019-01-01", status: "in progress", amount: 20)
        Invoice.create(partner: partner, date: "2019-01-01", status: "paid", amount: 20)
      end

      it 'only shows the in progress balance' do
        expect(partner.balance).must_equal 20
      end
    end
  end

  describe '#balance_in_currency' do
    let(:partner) { publishers(:completed_partner).becomes(Partner) }
    before do
      Invoice.destroy_all
      Invoice.create(partner: partner, status: "in progress",  date: "2019-01-01", amount: 200)
    end

    it 'adds invoices and displays in default currency' do
      expect('%.2f' % partner.balance_in_currency).must_equal "47.28"
    end
  end
end
