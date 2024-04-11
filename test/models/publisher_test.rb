# typed: false

require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class PublisherTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include MailerTestHelper
  include PromosHelper
  include EyeshadeHelper

  before(:example) do
    @prev_offline = Rails.configuration.pub_secrets[:api_eyeshade_offline]
  end

  after(:example) do
    Rails.configuration.pub_secrets[:api_eyeshade_offline] = @prev_offline
  end

  describe "#authorized_to_act?" do
    describe "when publisher is a member in good standing" do
      let(:publisher) { publishers(:verified) }
      it "should be true" do
        assert publisher.authorized_to_act?
      end
    end

    describe "when publisher is suspended" do
      let(:publisher) { publishers(:suspended) }
      it "should be false" do
        refute publisher.authorized_to_act?
      end
    end

    describe "when publisher has a blocked uphold connection" do
      let(:publisher) { publishers(:uphold_connected_blocked) }

      it "should be true" do
        assert publisher.authorized_to_act?
      end
    end

    describe "when publisher is using an uphold_id associated with >1 suspended accounts" do
      let(:publisher) { publishers(:verified) }
      let(:uphold_id) { "024e51fc-5513-4d82-882c-9b22024280cc" }

      before do
        publishers(:verified).suspend!
        UpholdConnection.update_all(uphold_id: uphold_id)
      end

      it "should be false" do
        refute publisher.authorized_to_act?
      end
    end
  end

  describe "#confirm_pending_email!" do
    let(:publisher) { publishers(:default) }

    describe "confirm_email" do
      describe "pending_email" do
        describe "!email" do
          it "should set email to pending_email" do
            publisher.email = nil
            publisher.pending_email = "test@email.com"
            publisher.confirm_pending_email!(nil)
            assert_equal publisher.email, "test@email.com"
          end
        end

        describe "confirm_email == pending_email" do
          it "should set email to pending_email" do
            publisher.pending_email = "test@email.com"
            publisher.confirm_pending_email!("test@email.com")
            assert_equal publisher.email, "test@email.com"
          end

          it "should set pending_email to nil" do
            publisher.pending_email = "test@email.com"
            publisher.confirm_pending_email!("test@email.com")
            assert_nil publisher.pending_email
          end
        end

        describe "confirm_email != pending_email" do
          it "should not change email" do
            publisher_email_old = publisher.email
            publisher.pending_email = "test@email.com"
            publisher.confirm_pending_email!("test2@email.com")
            assert_equal publisher.email, publisher_email_old
          end

          it "should set pending_email to nil" do
            publisher.pending_email = "test@email.com"
            publisher.confirm_pending_email!("test2@email.com")
            assert_nil publisher.pending_email
          end
        end
      end

      describe "!pending_email" do
        it "should not change the email" do
          assert_equal publisher, publisher.confirm_pending_email!("test@email.com")
          assert_equal publisher, publisher.confirm_pending_email!(nil)
        end
      end
    end
  end

  test "verified publishers have both a name and email and have agreed to the TOS" do
    publisher = Publisher.new
    refute publisher.email_verified?
    refute publisher.verified?

    publisher.email = "jane@example.com"
    assert publisher.email_verified?
    refute publisher.verified?

    publisher.name = "Jane"
    refute publisher.verified?

    publisher.agreed_to_tos = 1.minute.ago
    assert publisher.verified?
  end

  test "Publisher is able to have created_by assigned" do
    publisher = Publisher.new(email: "new@new.com")
    publisher.created_by = Publisher.first
    assert publisher.save
    assert Publisher.find_by(email: "new@new.com").created_by
  end

  test "Publisher is able to have not have a created_by set" do
    publisher = Publisher.new(email: "jane@example.com")
    assert publisher.valid?
    assert publisher.save
  end

  test "a publisher must have a valid pending email address if it does not have an email address" do
    publisher = Publisher.new

    assert_nil publisher.email
    assert_nil publisher.pending_email
    refute publisher.valid?

    publisher.pending_email = "foo@bar.com"
    assert publisher.valid?

    publisher.email = "foo@bar.com"
    publisher.pending_email = nil
    assert publisher.valid?

    publisher.email = "foo@bar.com"
    publisher.pending_email = "bar@bar.com"
    assert publisher.valid?
  end

  test "a publisher pending_email address must be valid" do
    publisher = Publisher.new

    publisher.pending_email = "bad_email_addresscom"
    refute publisher.valid?
  end

  test "a publisher pending_email address must not match an existing verified email address" do
    publisher = Publisher.new

    publisher.pending_email = "foo@bar.com"
    assert publisher.valid?

    publisher.pending_email = "alice@verified.org"
    refute publisher.valid?
  end

  test "a publisher pending_email address must not match the verified email address" do
    publisher = Publisher.new

    publisher.email = "foo@bar.com"
    assert publisher.valid?

    publisher.pending_email = "foo@bar.com"
    refute publisher.valid?
  end

  test "a publisher can be destroyed if it is not verified" do
    publisher = Publisher.new

    publisher.pending_email = "foo@foo.com"
    assert publisher.valid?
    publisher.save
    assert_difference("Publisher.count", -1) do
      assert publisher.destroy
    end
  end

  test "a publisher can not be destroyed if it has channels" do
    publisher = publishers(:verified)
    assert_difference("Publisher.count", 0) do
      refute publisher.destroy
    end
  end

  test "test `has_stale_uphold_code` scopes to correct publishers" do
    ActiveRecord::Base.record_timestamps = false
    publisher = publishers(:default)

    # verify there are no publishers with stale codes to begin with
    assert_equal UpholdConnection.has_stale_uphold_code.count, 0

    # verify scope includes publisher if uphold_code exist and exceeds timeout
    publisher.uphold_connection.uphold_code = "foo"
    publisher.uphold_connection.updated_at = UpholdConnection::UPHOLD_CODE_TIMEOUT.ago - 1.minute
    publisher.uphold_connection.save
    assert_equal UpholdConnection.has_stale_uphold_code.count, 1

    ActiveRecord::Base.record_timestamps = true
    # verify scope does not include publisher if uphold_code exists and within timeout
    publisher.uphold_connection.uphold_code = "bar"
    publisher.uphold_connection.save
    assert_equal UpholdConnection.has_stale_uphold_code.count, 0

    # verify scope does not include publisher if uphold_code does not exist and within timeout
    publisher.uphold_connection.uphold_code = nil
    publisher.uphold_connection.save
    assert_equal UpholdConnection.has_stale_uphold_code.count, 0

    ActiveRecord::Base.record_timestamps = false
    # verify scope does not include publisher if uphold_code does not exist and exceeds timeout
    publisher.uphold_connection.uphold_code = nil
    publisher.uphold_connection.updated_at = UpholdConnection::UPHOLD_CODE_TIMEOUT.ago - 1.minute
    publisher.uphold_connection.save!
    assert_equal UpholdConnection.has_stale_uphold_code.count, 0
    ActiveRecord::Base.record_timestamps = true
  end

  test "test `has_stale_access_params` scopes to correct publishers " do
    ActiveRecord::Base.record_timestamps = false
    publisher = publishers(:default)

    # verify there are no publishers with stale codes to begin with
    assert_equal UpholdConnection.has_stale_uphold_access_parameters.count, 0

    # verify scope includes publisher if uphold_access_params exist and exceeds timeout
    publisher.uphold_connection.uphold_access_parameters = "foo"
    publisher.uphold_connection.updated_at = UpholdConnection::UPHOLD_ACCESS_PARAMS_TIMEOUT.ago - 1.minute
    publisher.uphold_connection.save
    assert_equal UpholdConnection.has_stale_uphold_access_parameters.count, 1

    ActiveRecord::Base.record_timestamps = true
    # verify scope does not include publisher if uphold_access_params exists and within timeout
    publisher.uphold_connection.uphold_access_parameters = "bar"
    publisher.uphold_connection.save
    assert_equal UpholdConnection.has_stale_uphold_access_parameters.count, 0

    # verify scope does not include publisher if uphold_access_params does not exist and within timeout
    publisher.uphold_connection.uphold_access_parameters = nil
    publisher.uphold_connection.save
    assert_equal UpholdConnection.has_stale_uphold_access_parameters.count, 0

    ActiveRecord::Base.record_timestamps = false
    # verify scope does not include publisher if uphold_access_params does not exist and exceeds timeout
    publisher.uphold_connection.uphold_access_parameters = nil
    publisher.uphold_connection.updated_at = UpholdConnection::UPHOLD_CODE_TIMEOUT.ago - 1.minute
    publisher.uphold_connection.save!
    assert_equal UpholdConnection.has_stale_uphold_access_parameters.count, 0

    ActiveRecord::Base.record_timestamps = true
  end

  test "formats owner_identifier correctly" do
    publisher = publishers(:default)

    assert_equal "publishers#uuid:02e81b29-f150-54b9-9a08-ce75944f6889", publisher.owner_identifier
  end

  test "a publishers channel details can be selected from the publisher object" do
    publisher = publishers(:completed)
    site_channel_details = publisher.site_channel_details

    assert_equal site_channel_details.first.brave_publisher_id, "completed.org"

    publisher = publishers(:google_verified)
    youtube_channel_details = publisher.youtube_channel_details
    assert_equal youtube_channel_details.first.title, "Some Other Guy's Channel"
  end

  test "created status is added upon create" do
    publisher = Publisher.new(name: "Carol", pending_email: "carol@example.com")
    publisher.save!

    assert publisher.status_updates.count
    publisher.reload
    assert publisher.last_status_update
  end

  test "onboarding status added to new publishers when they email verify" do
    publisher = publishers(:created) # has no email address

    assert publisher.last_status_update.status == "created"

    publisher.email = "carol@example.com"
    publisher.save!

    assert publisher.last_status_update.status == "onboarding"
  end

  test "onboarding status not added to publishers when they change emails" do
    publisher = publishers(:completed) # has an email address

    publisher.email = "carol@example.com"
    publisher.save!

    refute publisher.last_status_update == "onboarding"
  end

  test "active status is added to publisher after agreeing TOS and addressing 2fa" do
    publisher = publishers(:onboarding)

    assert publisher.last_status_update.status == "onboarding"

    publisher.two_factor_prompted_at = Time.now
    publisher.agreed_to_tos = Time.now
    publisher.save!

    assert publisher.last_status_update.status == "active"
  end

  test "active status is not added to publishers who already agreed to TOS" do
    publisher = publishers(:completed)

    publisher.two_factor_prompted_at = Time.now
    publisher.agreed_to_tos = Time.now
    publisher.save!

    assert publisher.status_updates.count == 1
  end

  test "publisher.last_status_update gets pulls the most recent status update" do
    publisher = publishers(:created)

    # add onboarding status
    publisher.email = "carol@example.com"
    publisher.save!

    # add active status
    publisher.two_factor_prompted_at = Time.now
    publisher.agreed_to_tos = Time.now
    publisher.save!

    assert publisher.status_updates.count == 3
    assert publisher.last_status_update.status == "active"
  end

  test "suspended scope returns suspended publishers, not_suspended returns not suspended" do
    # ensure all suspended publishers are included in the scope
    suspended_publishers = Publisher.suspended
    not_suspended_publishers = Publisher.not_suspended
    suspended_publishers.each do |publisher|
      assert publisher.last_status_update, PublisherStatusUpdate::SUSPENDED
      assert not_suspended_publishers.exclude?(publisher)
    end

    not_suspended_publishers.each { |publisher| refute publisher.suspended? }

    # ensure a publisher that is unsuspended does not appear in scope
    publisher = publishers(:suspended)
    assert suspended_publishers.include?(publisher)
    status_update = PublisherStatusUpdate.new(status: "active", publisher: publisher)
    status_update.save!
    assert Publisher.suspended.exclude?(publisher)
    assert Publisher.not_suspended.include?(publisher)

    assert_equal Publisher.count, Publisher.suspended.count + Publisher.not_suspended.count
  end

  test "with_verified_channel scope only selects publishers with verified channels" do
    Publisher.with_verified_channel.each do |publisher|
      with_verified_channel = false # initialize to false

      publisher.channels.each do |channel|
        with_verified_channel = true if channel.verified?
      end

      assert with_verified_channel # should have been set to true by at least one channel
    end
  end

  test "with_verified_channel does not select two of the same publisher" do
    publishers = Publisher.with_verified_channel.select(:id)
    assert_equal publishers.uniq.length, publishers.length
  end

  test "#find_by_owner_identifier finds by owner identifier" do
    publisher = Publisher.first
    assert_equal Publisher.find_by_owner_identifier(publisher.owner_identifier), publisher
  end

  test "admin and not_admin scope return collections with only admins and non-admins respectively" do
    admin = publishers(:admin)
    not_admin = publishers(:default)

    assert_includes(Publisher.admin, admin)
    assert_not_includes(Publisher.admin, not_admin)
    assert_includes(Publisher.not_admin, not_admin)
    assert_not_includes(Publisher.not_admin, admin)
  end

  test "partner and not_partner scope return collections with only partners and non-partners respectively" do
    partner = publishers(:partner)
    not_partner = publishers(:default)

    assert_includes(Publisher.partner, partner)
    assert_not_includes(Publisher.partner, not_partner)
    assert_includes(Publisher.not_partner, not_partner)
    assert_not_includes(Publisher.not_partner, partner)
  end

  test "publisher channel_count" do
    result = Publisher.advanced_sort(Publisher::VERIFIED_CHANNEL_COUNT, "asc")
    assert_equal(
      Channel
      .where(verified: true)
      .joins(:publisher)
      .where(publishers: {role: Publisher::PUBLISHER})
      .pluck(:publisher_id)
      .uniq
      .count, result.length
    )
  end

  test "can have apostrophe in name" do
    pub = publishers(:verified)
    pub.name = "Rich O'Shannigan"
    pub.save
    refute pub.valid?
    assert_equal pub.errors.first.message, "contains html sequences"
  end

  describe "#sync_wallet_connections" do
    describe "when the publisher has a selected_wallet_provider" do
      let(:publisher) { publishers(:gemini_completed) }

      it "is true" do
        assert publisher.selected_wallet_provider
        assert publisher.sync_wallet_connections
      end
    end

    describe "when the publisher doesn't have a selected_wallet_provider" do
      let(:publisher) { publishers(:default) }

      it "is false" do
        assert !publisher.selected_wallet_provider
        assert !publisher.sync_wallet_connections
      end
    end

    describe "when the connection recently updated" do
      let(:publisher) { publishers(:gemini_completed) }

      before do
        publisher.selected_wallet_provider.updated_at = 2.days.ago
      end

      it "is false" do
        assert publisher.selected_wallet_provider
        assert !publisher.sync_wallet_connections
      end
    end
  end

  describe "#selected_wallet_provider" do
    describe "when the publisher has a selected_wallet_provider" do
      let(:publisher) { publishers(:publisher_selected_wallet_provider) }
      it "is the right kind" do
        assert publisher.selected_wallet_provider.class, UpholdConnection
      end
    end

    describe "when the publisher does not have the selected_wallet_provider" do
      let(:publisher) { publishers(:gemini_completed) }

      it "is the right kind" do
        assert publisher.selected_wallet_provider.class, GeminiConnection
      end
    end
  end

  describe "#feature_flags" do
    describe "#location_enabled?" do
      it "should return falsey" do
        assert !publishers(:default).location_enabled?
      end
    end
  end

  describe "brave_payable" do
    it "should return falsey if excluded_from_payout" do
      p = publishers(:default)
      assert p.brave_payable?
      p.excluded_from_payout = true
      p.save!
      refute p.brave_payable?
    end
  end

  describe "#history" do
    describe "when the publisher has notes" do
      it "shows just the notes" do
        histories = publishers(:just_notes).history
        histories.each do |history|
          assert_equal history.class, PublisherNote
        end
      end
    end

    describe "when the publisher has notes and statuses" do
      it "interweaves the objects" do
        histories = publishers(:notes).history

        assert histories.any? { |h| h.is_a? PublisherNote }
        assert histories.any? { |h| h.is_a? PublisherStatusUpdate }
      end

      it "sorts the object by created_at time" do
        histories = publishers(:notes).history
        histories.each_with_index do |history, index|
          next if index == 0
          assert history.created_at < histories[index - 1].created_at
        end
      end
    end

    describe "when the publisher just has statuses" do
      it "just shows the statuses" do
        histories = publishers(:default).history
        histories.each do |history|
          assert_equal history.class, PublisherStatusUpdate
        end
      end
    end
  end
end
