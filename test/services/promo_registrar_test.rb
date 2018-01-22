require "test_helper"
require "webmock/minitest"

class PromoRegistrarTest < ActiveJob::TestCase
  include PromosHelper
  test "registrar registers a verified channel" do
    publisher = publishers(:completed) # has one verified channel

    assert_difference "PromoRegistration.count", 1 do
      PromoRegistrar.new(publisher: publisher).perform
    end
  end

  test "registrar does not register unverified channel" do
    publisher = publishers(:default) # has two unverified channels

    assert_no_difference "PromoRegistration.count" do
      PromoRegistrar.new(publisher: publisher).perform
    end
  end

  test "registrar does not attempt make api call if channel registered" do
    publisher = publishers(:completed)
    channel = publisher.channels.first

    registrar = PromoRegistrar.new(publisher: publisher)

    # verify we make the call once
    make_first_api_call = registrar.instance_eval { should_register_channel?(channel) }
    assert make_first_api_call

    # actually register the channel
    registrar.perform
    channel.reload

    # verify that we do not attempt a second api call
    make_second_api_call = registrar.instance_eval { should_register_channel?(channel) }
    assert !make_second_api_call

    # verify no registrations created for good measure
    assert_no_difference "PromoRegistration.count" do
      registrar.perform
    end
  end

  test "registrar registers > 5 channels asynchronously" do
    # create 5 verified channels
    # TO DO: either create a fixture that has 5 channels of find a way
    #        to generate an arbitrary number of valid channels
  end

  test "registrar requests promo code for channel if encounters duplicate error" do
    publisher = publishers(:completed)

    # Force use register_channel, not register_channel_offline
    PromoRegistrationsController.any_instance.stubs(:perform_promo_offline?).returns(false)

    # Force duplicate error    
    stub_request(:put, "#{Rails.application.secrets[:api_promi_base_uri]}/api/1/promo/publishers")
      .to_return(status: 409)
    
    assert_difference "PromoRegistration.count", 1 do
      PromoRegistrar.new(publisher: publisher).perform
    end
  end
end