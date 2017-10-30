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

  test "`expired` scope includes all expired statements" do
    publisher = publishers(:verified)
    statement1 = PublisherStatement.new(publisher: publisher, period: 'past_7_days')
    statement1.save
    statement2 = PublisherStatement.new(publisher: publisher, period: 'past_7_days')
    statement2.save
    statement3 = PublisherStatement.new(publisher: publisher, period: 'past_7_days')
    statement3.save

    statement2.expires_at = 2.days.ago
    statement2.save

    statement3.expires_at = 1.minute.ago
    statement3.save

    assert_equal 2,PublisherStatement.expired.count
  end
end
