require "test_helper"
require "webmock/minitest"

class PublisherPromoTokenGeneratorTest < ActiveJob::TestCase
  include PromosHelper

  test "generator generates 2018q1 token" do 
    publisher = publishers(:completed)
    PublisherPromoTokenGenerator.any_instance.stubs(:active_promo_id).returns("free-bats-2018q1")
    PublisherPromoTokenGenerator.new(publisher: publisher).perform

    assert_not_nil publisher.promo_token_2018q1
  end

  test "generator doesn't overwrite existing 2018q1 token" do
    publisher = publishers(:completed)
    PublisherPromoTokenGenerator.any_instance.stubs(:active_promo_id).returns("free-bats-2018q1")
    generator = PublisherPromoTokenGenerator.new(publisher: publisher)

    # generate token
    generator.perform
    promo_token = publisher.promo_token_2018q1

    # verify generator doesn't overwrite existing token
    generator.perform
    assert_equal promo_token, publisher.promo_token_2018q1
  end

  test "generator will overwrite existing 2018q1 token with param force=true" do
    publisher = publishers(:completed)
    PublisherPromoTokenGenerator.any_instance.stubs(:active_promo_id).returns("free-bats-2018q1")
    PublisherPromoTokenGenerator.new(publisher: publisher).perform

    first_promo_token = publisher.promo_token_2018q1
    PublisherPromoTokenGenerator.new(publisher: publisher, force: true).perform
    second_promo_token = publisher.promo_token_2018q1

    assert_not_equal first_promo_token, second_promo_token
  end

  test "generator raises error if promo_id is invalid, no 2018q1 tokens are generated" do
    publisher = publishers(:completed)

    # use invalid active_promo_id
    PublisherPromoTokenGenerator.any_instance.stubs(:active_promo_id).returns("invalid-promo-id")
    
    assert_raise PublisherPromoTokenGenerator::InvalidPromoIdError do
      PublisherPromoTokenGenerator.new(publisher: publisher).perform
    end
  end
end