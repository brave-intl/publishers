require "test_helper"
require "webmock/minitest"

class PublisherStatementSyncerTest < ActiveJob::TestCase
  def setup
    @prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    Rails.application.secrets[:api_eyeshade_offline] = false
  end

  def teardown
    Rails.application.secrets[:api_eyeshade_offline] = @prev_api_eyeshade_offline
  end

  test "retrieves and saves the publisher statement contents, and sends a notification email" do
    stub_request(:get, /report\/123/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: "abc", headers: {})

    publisher = publishers(:verified)

    publisher_statement = PublisherStatement.new(
      publisher: publisher,
      period: :all,
      source_url: '/report/123')
    publisher_statement.save!

    perform_enqueued_jobs do
      PublisherStatementSyncer.new(publisher_statement: publisher_statement).perform
    end

    publisher_statement.reload
    assert_equal "abc", publisher_statement.contents

    refute ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal [publisher.email], email.to
    assert_equal I18n.t('publisher_mailer.statement_ready.subject', publication_title: publisher.publication_title), email.subject
  end

  test "retrieves the publisher statement contents - but does nothing if contents are not retrieved" do
    stub_request(:get, /report\/123/).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 404, body: nil, headers: {})

    publisher = publishers(:verified)

    publisher_statement = PublisherStatement.new(
      publisher: publisher,
      period: :all,
      source_url: '/report/123')
    publisher_statement.save!

    assert_no_enqueued_jobs do
      PublisherStatementSyncer.new(publisher_statement: publisher_statement).perform
    end

    publisher_statement.reload
    assert_nil publisher_statement.contents
  end
end