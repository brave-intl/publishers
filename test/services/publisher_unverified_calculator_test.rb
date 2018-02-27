require 'test_helper'
require "webmock/minitest"
class PublisherUnverifiedCalculatorTest < ActiveJob::TestCase
  test "only returns publishers with an unverified channel within the window" do

    publisher_dave = Publisher.create!(
      name: "Dave",
      email: "dave@brave.com"
    )

    publisher_dave.channels.new(
      verified: true
    ).save!(validate: false)

    # Create a verified: false channel. This causes publisher_dave to
    # be in the win back list
    publisher_dave.channels.new(
      verified: false
    ).save!(validate: false)

    # Create a second verified: false. Despite this the publisher should
    # only be in the final list once
    publisher_dave.channels.new(
      verified: false
    ).save!(validate: false)

    publisher_alice = Publisher.create!(
      name: "Alice",
      email: "alice@brave.com",
      phone: "15555555555",
      phone_normalized: "+15555555555"
    )

    publisher_alice.channels.new(
      verified: true
    ).save!(validate: false)

    calculator = PublisherUnverifiedCalculator.new

    publishers = calculator.perform
    assert_not_includes publishers, publisher_dave
    assert_not_includes publishers, publisher_alice
    assert_equal [], publishers

    travel PublisherUnverifiedCalculator::WIN_BACK_THRESHOLD + 1.second do
      publishers = calculator.perform
      assert_includes publishers, publisher_dave
      assert_not_includes publishers, publisher_alice
      assert_equal publishers.uniq, publishers
    end

    travel PublisherUnverifiedCalculator::WIN_BACK_MAX_AGE + 1.second do
      publishers = calculator.perform
      assert_not_includes publishers, publisher_dave
      assert_not_includes publishers, publisher_alice
      assert_equal publishers.uniq, publishers
    end
  end
end
