require "test_helper"
require "webmock/minitest"

class SyncPublisherStatementTest < ActiveJob::TestCase
  def setup
    @prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    Rails.application.secrets[:api_eyeshade_offline] = false
  end

  def teardown
    Rails.application.secrets[:api_eyeshade_offline] = @prev_api_eyeshade_offline
  end

  test "does nothing if a statement already has contents" do
    publisher = publishers(:verified)

    publisher_statement = PublisherStatement.new(
      publisher: publisher,
      period: :all,
      source_url: '/report/123',
      contents: 'abc')
    publisher_statement.save!

    assert_no_enqueued_jobs do
      SyncPublisherStatementJob.perform_now(publisher_statement_id: publisher_statement.id)
    end

    publisher_statement.reload
    assert_equal 'abc', publisher_statement.contents
  end

  test "syncs statement and will not reschedule if contents have been set" do
    stub_request(:get, /report\/123/).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: "abc", headers: {})

    publisher = publishers(:verified)
    publisher_statement = PublisherStatement.new(
      publisher: publisher,
      period: :all,
      source_url: '/report/123')
    publisher_statement.save!

    assert_no_enqueued_jobs(only: SyncPublisherStatementJob) do
      SyncPublisherStatementJob.perform_now(publisher_statement_id: publisher_statement.id)
    end

    publisher_statement.reload
    assert_equal 'abc', publisher_statement.contents
  end

  test "syncs statement and will reschedule itself if contents have not been set" do
    publisher = publishers(:verified)
    publisher_statement = PublisherStatement.new(
      publisher: publisher,
      period: :all,
      source_url: '/report/123')
    publisher_statement.save!

    stub_request(:get, /report\/123/).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 404, headers: {})

    assert_enqueued_jobs(1, only: SyncPublisherStatementJob) do
      SyncPublisherStatementJob.perform_now(publisher_statement_id: publisher_statement.id)
    end
  end
end
