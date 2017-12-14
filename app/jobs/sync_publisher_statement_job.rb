class SyncPublisherStatementJob < ApplicationJob
  queue_as :default

  def perform(publisher_statement_id:, first_attempt: nil)
    require "sentry-raven"
    if first_attempt
      time_elapsed = Time.now.to_i - first_attempt
      if time_elapsed > 3.minutes
        Raven.capture_message('SyncPublisherStatementJob timed out', publisher_statement_id: publisher_statement_id)
        return
      end
    else
      first_attempt = Time.now.to_i
      time_elapsed = 0
    end

    publisher_statement = PublisherStatement.find(publisher_statement_id)

    PublisherStatementSyncer.new(publisher_statement: publisher_statement).perform

    publisher_statement.reload

    unless publisher_statement.contents.present?
      SyncPublisherStatementJob.set(wait: wait_to_retry(time_elapsed)).perform_later(publisher_statement_id: publisher_statement.id, first_attempt: first_attempt)
    end
  end

  private

  def wait_to_retry(time_elapsed)
    if time_elapsed < 20.seconds
      3.seconds
    elsif time_elapsed < 1.minute
      5.seconds
    elsif time_elapsed < 2.minutes
      8.seconds
    else
      10.seconds
    end
  end
end
