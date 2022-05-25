require "test_helper"

class RedisCountServiceTest < ActiveSupport::TestCase
  subject { RedisCountService }
  let(:instance) { subject.new }
  let(:key) { "test-key" }

  describe "#initialize" do
    describe "when successful" do
      it "should return an instance" do
        assert_instance_of(subject, instance)
      end
    end

    describe "#call" do
      describe "when server is !available" do
        before do
          Redis.any_instance.stubs(:incr).raises(Redis::CannotConnectError)
        end

        it "should return BFailure" do
          assert_instance_of(BFailure, instance.call(key))
        end
      end

      describe "when server is available" do
        before do
          Redis.any_instance.stubs(:incr).returns(10)
        end

        describe "when <= limit" do
          it "should return falsey" do
            assert_instance_of(RedisCountService::BelowLimit, instance.call(key))
          end
        end

        describe "when > limit" do
          before do
            Redis.any_instance.stubs(:incr).returns(11)
          end

          it "should return truthy" do
            assert_instance_of(RedisCountService::AboveLimit, instance.call(key))
          end
        end
      end
    end
  end
end
