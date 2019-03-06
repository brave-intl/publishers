require "test_helper"

class PartnerTest < ActiveSupport::TestCase
  test "All partners will have role of Partner" do
    p = Partner.new(email: 'test@example.com')
    assert p.partner?
  end

  describe 'when balance is called' do
    let(:partner) { partners(:default_partner) }
    before do
      Invoice.destroy_all
      Invoice.create(partner: partner, date: "2019-01-01", amount: 20)
    end

    it 'adds the total amount of invoices' do
      expect(partner.balance).must_equal 20
    end
  end

  describe '#balance_in_currency' do
    let(:partner) { publishers(:completed_partner).becomes(Partner) }
    before do
      Invoice.destroy_all
      Invoice.create(partner: partner, date: "2019-01-01", amount: 200)
    end

    it 'adds invoices and displays in default currency' do
      expect('%.2f' % partner.balance_in_currency).must_equal 47.28
    end
  end
end
