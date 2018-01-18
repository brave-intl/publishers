require "test_helper"
require "rake/testtask"
require "legacy_data"

class TransformLegacyDataTest < ActiveJob::TestCase
  extend LegacyData

  before do
    require 'rake'
    load File.expand_path("../../../lib/tasks/temp/transform_legacy_data.rake", __FILE__)

    Rake::Task.define_task :environment

    # Redirect stdout to silence output
    @original_stdout = $stdout
    $stdout = File.open(File::NULL, "w")
  end

  after do
    Rake::Task.clear
    # Reenable output
    $stdout = @original_stdout
  end

  test "imports publishers - uphold verified" do
    LegacyData::LegacyPublisher.new(
        {
            brave_publisher_id: "company.com",
            name: "NAME",
            email: "user@company.com",
            verification_token: "VERIFICATION_TOKEN",
            verified: true,
            created_at: "2017-11-28 10:11:12",
            updated_at: "2017-11-28 12:10:45",
            sign_in_count: 123,
            current_sign_in_at: "2017-11-28 12:10:45",
            last_sign_in_at: "2017-11-28 12:10:45",
            phone: "6035551212",
            phone_normalized: "\+16035551212",
            authentication_token: "asdfg",
            verification_method: "wordpress",
            authentication_token_expires_at: "2017-11-30 10:20:30",
            show_verification_status: false,
            created_via_api: false,
            uphold_state_token: "UPHOLDSTATETOKEN",
            uphold_code: nil,
            uphold_access_parameters: nil,
            uphold_verified: true,
            pending_email: "new_user@company.com",
            supports_https: true,
            host_connection_verified: true,
            detected_web_host: "wordpress",
            default_currency: "BAT",
            brave_publisher_id_unnormalized: "COMPANY.COM",
            brave_publisher_id_error_code: nil,
            uphold_updated_at: "2017-11-30 20:30:40"
        }
    ).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      pub = Publisher.find_by(email: "user@company.com")
      assert_equal "NAME", pub.name
      assert_equal "user@company.com", pub.email
      assert_equal "6035551212", pub.phone
      assert_equal "\+16035551212", pub.phone_normalized

      assert_equal Time.zone.parse("2017-11-28 10:11:12"), pub.created_at
      assert_equal "UPHOLDSTATETOKEN", pub.uphold_state_token
      assert pub.uphold_verified
      assert_equal "BAT",  pub.default_currency
      refute pub.visible

      # not carried over
      refute_equal Time.zone.parse("2017-11-28 12:10:45"), pub.updated_at
      assert_equal 0, pub.sign_in_count
      assert_nil pub.current_sign_in_at
      assert_nil pub.last_sign_in_at
      assert_nil pub.authentication_token
      assert_nil pub.authentication_token_expires_at
      assert_nil pub.pending_email
      # uphold_updated_at auto set
      assert pub.uphold_updated_at
      refute pub.created_via_api
      assert_nil pub.uphold_code
      assert_nil pub.uphold_access_parameters
    end
  end

  test "imports publishers - NOT uphold verified" do
    LegacyData::LegacyPublisher.new(
        {
            brave_publisher_id: "company.com",
            name: "NAME",
            email: "user@company.com",
            verification_token: "VERIFICATION_TOKEN",
            verified: true,
            created_at: "2017-11-28 10:11:12",
            updated_at: "2017-11-28 12:10:45",
            sign_in_count: 123,
            current_sign_in_at: "2017-11-28 12:10:45",
            last_sign_in_at: "2017-11-28 12:10:45",
            phone: "6035551212",
            phone_normalized: "\+16035551212",
            authentication_token: "asdfg",
            verification_method: "wordpress",
            authentication_token_expires_at: "2017-11-30 10:20:30",
            show_verification_status: true,
            created_via_api: false,
            uphold_state_token: nil,
            uphold_code: nil,
            uphold_access_parameters: nil,
            uphold_verified: false,
            pending_email: "new_user@company.com",
            supports_https: true,
            host_connection_verified: true,
            detected_web_host: "wordpress",
            default_currency: "BAT",
            brave_publisher_id_unnormalized: "COMPANY.COM",
            brave_publisher_id_error_code: nil,
            uphold_updated_at: "2017-11-30 20:30:40"
        }
    ).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      pub = Publisher.find_by(email: "user@company.com")
      assert_equal "NAME", pub.name
      assert_equal "user@company.com", pub.email
      assert_equal "6035551212", pub.phone
      assert_equal "\+16035551212", pub.phone_normalized

      assert_equal Time.zone.parse("2017-11-28 10:11:12"), pub.created_at
      assert_nil pub.uphold_state_token
      refute pub.uphold_verified
      assert_equal "BAT", pub.default_currency
      assert pub.visible

      # not carried over
      refute_equal Time.zone.parse("2017-11-28 12:10:45"), pub.updated_at
      assert_equal 0, pub.sign_in_count
      assert_nil pub.current_sign_in_at
      assert_nil pub.last_sign_in_at
      assert_nil pub.authentication_token
      assert_nil pub.authentication_token_expires_at
      assert_nil pub.pending_email
      # uphold_updated_at auto set
      assert_nil pub.uphold_updated_at
      refute pub.created_via_api
      assert_nil pub.uphold_code
      assert_nil pub.uphold_access_parameters
    end
  end

  test "imports channel" do
    LegacyData::LegacyPublisher.new(
        {
            brave_publisher_id: "company.com",
            name: "NAME",
            email: "user@company.com",
            verification_token: "VERIFICATION_TOKEN",
            verified: true,
            created_at: "2017-11-28 10:11:12",
            updated_at: "2017-11-28 12:10:45",
            sign_in_count: 123,
            current_sign_in_at: "2017-11-28 12:10:45",
            last_sign_in_at: "2017-11-28 12:10:45",
            phone: "6035551212",
            phone_normalized: "\+16035551212",
            authentication_token: "asdfg",
            verification_method: "wordpress",
            authentication_token_expires_at: "2017-11-30 10:20:30",
            show_verification_status: false,
            created_via_api: false,
            uphold_state_token: "UPHOLDSTATETOKEN",
            uphold_code: nil,
            uphold_access_parameters: nil,
            uphold_verified: true,
            pending_email: "new_user@company.com",
            supports_https: true,
            host_connection_verified: true,
            detected_web_host: "wordpress",
            default_currency: "BAT",
            brave_publisher_id_unnormalized: "COMPANY.COM",
            brave_publisher_id_error_code: nil,
            uphold_updated_at: "2017-11-30 20:30:40"
        }
    ).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      pub = Publisher.find_by(email: "user@company.com")
      channel = pub.channels[0]

      assert_equal true, channel.verified
      assert_equal Time.zone.parse("2017-11-28 10:11:12"), channel.created_at
    end
  end

  test "imports site channel details" do
    LegacyData::LegacyPublisher.new(
        {
            brave_publisher_id: "company.com",
            name: "NAME",
            email: "user@company.com",
            verification_token: "VERIFICATION_TOKEN",
            verified: true,
            created_at: "2017-11-28 10:11:12",
            updated_at: "2017-11-28 12:10:45",
            sign_in_count: 123,
            current_sign_in_at: "2017-11-28 12:10:45",
            last_sign_in_at: "2017-11-28 12:10:45",
            phone: "6035551212",
            phone_normalized: "\+16035551212",
            authentication_token: "asdfg",
            verification_method: "wordpress",
            authentication_token_expires_at: "2017-11-30 10:20:30",
            show_verification_status: false,
            created_via_api: false,
            uphold_state_token: "UPHOLDSTATETOKEN",
            uphold_code: nil,
            uphold_access_parameters: nil,
            uphold_verified: true,
            pending_email: "new_user@company.com",
            supports_https: true,
            host_connection_verified: true,
            detected_web_host: "wordpress",
            default_currency: "BAT",
            brave_publisher_id_unnormalized: "COMPANY.COM",
            brave_publisher_id_error_code: nil,
            uphold_updated_at: "2017-11-30 20:30:40"
        }
    ).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      pub = Publisher.find_by(email: "user@company.com")
      details = pub.channels[0].details

      assert details.is_a?(SiteChannelDetails)
      assert_equal "company.com", details.brave_publisher_id
      assert_equal "VERIFICATION_TOKEN", details.verification_token
      assert_equal "wordpress", details.verification_method
      assert details.supports_https
      assert details.host_connection_verified
      assert_equal "wordpress", details.detected_web_host
      assert_equal Time.zone.parse("2017-11-28 10:11:12"), details.created_at
    end
  end

  test "imports youtube channel details" do
    LegacyData::LegacyYoutubeChannel.new(
        {
            id: "YTC1289",
            title: "Funny Cats",
            description: "More funny cats than you can stand",
            thumbnail_url: "http://icons.com/cats.jpg",
            subscriber_count: 4500000
        }
    ).save!

    LegacyData::LegacyPublisher.new(
        {
            # brave_publisher_id: "company.com",
            name: "NAME",
            email: "user@company.com",
            # verification_token: "VERIFICATION_TOKEN",
            verified: true,
            created_at: "2017-11-28 10:11:12",
            updated_at: "2017-11-28 12:10:45",
            sign_in_count: 123,
            current_sign_in_at: "2017-11-28 12:10:45",
            last_sign_in_at: "2017-11-28 12:10:45",
            phone: "6035551212",
            phone_normalized: "\+16035551212",
            authentication_token: "asdfg",
            authentication_token_expires_at: "2017-11-30 10:20:30",
            created_via_api: false,
            uphold_state_token: "UPHOLDSTATETOKEN",
            uphold_code: nil,
            uphold_access_parameters: nil,
            uphold_verified: true,
            pending_email: "new_user@company.com",
            default_currency: "BAT",
            auth_provider: "google_oauth2",
            auth_user_id: "105659544661947994134",
            auth_name: "Some Name",
            auth_email: "random.email@google.com",
            youtube_channel_id: "YTC1289",
            uphold_updated_at: "2017-11-30 20:30:40"
        }
    ).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      pub = Publisher.find_by(email: "user@company.com")
      details = pub.channels[0].details

      assert details.is_a?(YoutubeChannelDetails)
      assert pub.channels[0].verified
      assert_equal "google_oauth2", details.auth_provider
      assert_equal "105659544661947994134", details.auth_user_id
      assert_equal "Some Name", details.auth_name
      assert_equal "random.email@google.com", details.auth_email
      assert_equal "YTC1289", details.youtube_channel_id
      assert_equal "Funny Cats", details.title
      assert_equal "More funny cats than you can stand", details.description
      assert_equal "http://icons.com/cats.jpg", details.thumbnail_url
      assert_equal 4500000, details.subscriber_count
    end
  end

  test "converts email_verified publishers to unique owners and many channels" do
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site1.com"}).save!
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site2.com"}).save!
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site3.com"}).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      assert_equal 1, Publisher.where(email: "user@company.com").count
      assert_equal 3, Publisher.find_by(email: "user@company.com").channels.count
    end
  end

  test "consolidates site and youtube channels" do
    LegacyData::LegacyYoutubeChannel.new({id: "123456", title: "My Channel", thumbnail_url: "http://foo.com"}).save!
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, youtube_channel_id: "123456",
                                     auth_user_id: "asdfg", auth_name: "fred", auth_provider: "google_oauth2", auth_email: "a@a.com"}).save!
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site2.com"}).save!
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site3.com"}).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      assert_equal 1, Publisher.where(email: "user@company.com").count
      assert_equal 3, Publisher.find_by(email: "user@company.com").channels.count
      channel_details = YoutubeChannelDetails.find_by(youtube_channel_id: "123456")
      publisher = Publisher.find_by(email: "user@company.com")
      assert_equal publisher.id, channel_details.channel.publisher.id
    end
  end

  test "when consolidating many channels visible is true if all channels show_verification_status" do
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site1.com", show_verification_status: true}).save!
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site2.com", show_verification_status: true}).save!
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site3.com", show_verification_status: true}).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      assert_equal 1, Publisher.where(email: "user@company.com").count
      assert Publisher.find_by(email: "user@company.com").visible
    end
  end

  test "when consolidating many channels visible is false if any channels do not show_verification_status" do
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site1.com", show_verification_status: true}).save!
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site2.com", show_verification_status: false}).save!
    LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site3.com", show_verification_status: true}).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      assert_equal 1, Publisher.where(email: "user@company.com").count
      refute Publisher.find_by(email: "user@company.com").visible
    end
  end

  test "brings over a u2f_registration" do
    leg_pub = LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site1.com"})
    leg_pub.save!

    LegacyData::LegacyU2fRegistration.new(
        {
            publisher_id: leg_pub.id,
            name: "aa",
            certificate: "cert",
            counter: 1,
            key_handle: "KEYHANDLE",
            public_key: "PUBLICKEY"

        }).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      assert_equal 1, Publisher.where(email: "user@company.com").count
      publisher = Publisher.find_by(email: "user@company.com")
      assert_equal 1, publisher.u2f_registrations.count
      registration = publisher.u2f_registrations[0]

      assert_equal "aa", registration.name
      assert_equal "cert", registration.certificate
      assert_equal 1, registration.counter
      assert_equal "KEYHANDLE", registration.key_handle
      assert_equal "PUBLICKEY", registration.public_key
    end
  end

  test "brings over u2f_registrations from multiple publishers" do
    leg_pub = LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site1.com"})
    leg_pub.save!
    LegacyData::LegacyU2fRegistration.new({publisher_id: leg_pub.id, name: "aa", certificate: "cert", counter: 1}).save!
    leg_pub = LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site2.com"})
    leg_pub.save!

    LegacyData::LegacyU2fRegistration.new({publisher_id: leg_pub.id, name: "bb", certificate: "cert2", counter: 2}).save!
    LegacyData::LegacyU2fRegistration.new({publisher_id: leg_pub.id, name: "cc", certificate: "cert3", counter: 3}).save!


    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      assert_equal 1, Publisher.where(email: "user@company.com").count
      assert_equal 2, Publisher.find_by(email: "user@company.com").channels.count

      publisher = Publisher.find_by(email: "user@company.com")
      assert_equal 3, publisher.u2f_registrations.count
    end
  end

  test "brings over a totp_registration" do
    leg_pub = LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site1.com"})
    leg_pub.save!

    LegacyData::LegacyTotpRegistration.new(
        {
            publisher_id: leg_pub.id,
            secret: "this is a secret",
            last_logged_in_at: "2017-11-30 10:20:30"
        }
    ).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      assert_equal 1, Publisher.where(email: "user@company.com").count
      publisher = Publisher.find_by(email: "user@company.com")

      registration = publisher.totp_registration
      assert_equal "this is a secret", registration.secret
      assert_equal Time.zone.parse("2017-11-30 10:20:30"), registration.last_logged_in_at
    end
  end

  test "does not bring over any totp_registrations if more than one is found for an owner" do
    leg_pub = LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site1.com"})
    leg_pub.save!

    LegacyData::LegacyTotpRegistration.new(
        {
            publisher_id: leg_pub.id,
            secret: "this is a secret",
            last_logged_in_at: "2017-11-30 10:20:30"
        }
    ).save!

    leg_pub = LegacyData::LegacyPublisher.new({email: "user@company.com", verified: true, brave_publisher_id: "site2.com"})
    leg_pub.save!

    LegacyData::LegacyTotpRegistration.new(
        {
            publisher_id: leg_pub.id,
            secret: "this is secret two",
            last_logged_in_at: "2017-12-30 10:20:30"
        }
    ).save!

    Rake::Task["publishers:transform_legacy_data"].invoke("[:commit]")

    Rake::TestTask.new do
      assert_equal 1, Publisher.where(email: "user@company.com").count
      publisher = Publisher.find_by(email: "user@company.com")

      assert_nil publisher.totp_registration
    end
  end
end