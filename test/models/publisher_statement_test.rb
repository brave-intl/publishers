require 'test_helper'

class PublisherStatementTest < ActiveSupport::TestCase
  test "statements can be created with a publisher and a period" do
    publisher = publishers(:verified)
    statement = PublisherStatement.new(publisher: publisher, period: 'past_7_days')
    assert statement.save
  end

  test "statements are assigned an expiration date" do
    publisher = publishers(:verified)
    statement = PublisherStatement.new(publisher: publisher, period: 'past_7_days')
    statement.save
    assert statement.expires_at > Time.zone.now
    refute statement.expired?
  end
end
