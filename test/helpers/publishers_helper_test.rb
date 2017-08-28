require 'test_helper'

class PublishersHelperTest < ActionView::TestCase
  test "should render brave publisher id as a link" do
    publisher = publishers(:default)
    assert_dom_equal %{<a href="http://#{publisher.brave_publisher_id}">#{publisher.brave_publisher_id}</a>},
                     link_to_brave_publisher_id(publisher)
  end
end
