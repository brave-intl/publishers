require 'test_helper'

class PublisherUnverifiedCalculatorTest < ActiveJob::TestCase
  test "only returns unverified publishers who don't share an email, brave_publisher_id, or phone number with a verified publisher" do
    # clear database
    Publisher.delete_all

    # create unverified publisher with same brave_id first to bypass model validation
    unverified_same_brave_id = Publisher.new(name: "Dave", brave_publisher_id: "default.org", verified: false, pending_email: "dave@default.org", email: "dave@default.org")
    unverified_same_brave_id.save!

    # check a verified publisher is not a win_back publisher
    verified = Publisher.new(name: "Alice",
                             brave_publisher_id: "default.org",
                             verified: true,
                             pending_email: "alice@default.org",
                             email: "alice@default.org",
                             phone: "15555555555",
                             phone_normalized: "+15555555555")
    verified.save!
    travel PublisherUnverifiedCalculator::WIN_BACK_THRESHOLD + 1.second
    calculator = PublisherUnverifiedCalculator.new
    publishers = calculator.perform
    assert_empty publishers

    # check unverifed publisher with same brave_publisher_id as a verified publisher is not a win back publisher
    publishers = calculator.perform
    assert !publishers.include?(unverified_same_brave_id)

    # check unverified publisher with no brave_publisher_id is not win back publisher
    unverified_without_brave_id = Publisher.new(verified: false, pending_email: "carol@default.org")
    unverified_without_brave_id.save!
    travel PublisherUnverifiedCalculator::WIN_BACK_THRESHOLD + 1.second
    publishers = calculator.perform
    assert !publishers.include?(unverified_without_brave_id)

    # check unverified publisher with same email as a verified publisher is not a win back publisher
    unverified_same_email = Publisher.new(name: "Alice", verified: false, pending_email: "alice@default.org", email: "alice@default.org")
    unverified_same_email.save!
    travel PublisherUnverifiedCalculator::WIN_BACK_THRESHOLD + 1.second
    publishers = calculator.perform
    assert !publishers.include?(unverified_same_email)

    # check unverified publisher with same phone number as as verified pubilsher is not a win back publisher
    unverified_same_phone = Publisher.new(name: "Carol", verified: false, pending_email: "carol@default.org", phone: "15555555555", phone_normalized: "+15555555555")
    unverified_same_phone.save!
    travel PublisherUnverifiedCalculator::WIN_BACK_THRESHOLD + 1.second
    publishers = calculator.perform
    assert !publishers.include?(unverified_same_phone)

    # create a valid win_back publisher (unique brave_id, email, phone)
    win_back_publisher = Publisher.new(name: "Bob", brave_publisher_id: "brave.com", verified: false, email: "bob@default.org")
    win_back_publisher.save!
    publishers = calculator.perform
    # verify not a win_back publisher if threshold time has not passed
    assert !publishers.include?(win_back_publisher)
    # verify is win_back publisher after threshold time passes
    travel PublisherUnverifiedCalculator::WIN_BACK_THRESHOLD + 1.second
    publishers = calculator.perform
    assert publishers.include?(win_back_publisher)
  end
end

