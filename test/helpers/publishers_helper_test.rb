require 'test_helper'

class PublishersHelperTest < ActionView::TestCase
  test "should render brave publisher id as a link" do
    publisher = publishers(:default)
    assert_dom_equal %{<a href="http://#{publisher.brave_publisher_id}">#{publisher.brave_publisher_id}</a>},
                     link_to_brave_publisher_id(publisher)
  end

  test "publisher_converted_balance should return nothing for unset publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = nil
    publisher.save
    assert_dom_equal %{}, publisher_converted_balance(publisher)
  end

  test "publisher_converted_balance should return nothing for BAT publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = "BAT"
    publisher.save
    assert_dom_equal %{}, publisher_converted_balance(publisher)
  end

  test "publisher_converted_balance should return something for set publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = "USD"
    publisher.save
    assert_dom_equal %{Approximately 9001.00 USD}, publisher_converted_balance(publisher)
  end
end
