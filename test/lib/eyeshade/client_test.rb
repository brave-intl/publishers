# typed: false
require "test_helper"

class EyeshadeClientTest < ActiveSupport::TestCase
  include EyeshadeHelper
  include Eyeshade::Types

  let(:described_class) { Eyeshade::Client }
  let(:inst) { described_class.new }
  let(:id) { "some_id" }
  let(:payload) { {body: "some content"} }

  describe "#init" do
    it "should return self" do
      assert_instance_of(Eyeshade::Client, inst)
    end
  end

  describe "#accounts_balances" do
    let(:payload) { {body: "some content"} }
    let(:publisher) { publishers(:default) }

    before do
      stub_request(:post, /v1\/accounts\/balances/)
        .to_return(status: 200, body: Mocks.accounts_balances.to_json)
    end

    test "should return array" do
      result = inst.accounts_balances(payload)
      assert_instance_of(Array, result)
    end
  end

  describe "#transactions" do
    let(:payload) { "identifier" }
    let(:publisher) { publishers(:default) }

    before do
      stub_request(:get, /v1\/accounts\/identifier\/transactions/)
        .to_return(status: 200, body: Mocks.account_transactions.to_json)
    end

    test "should return array" do
      result = inst.account_transactions(payload)
      assert_instance_of(Array, result)
    end
  end
end
