require 'test_helper'
require "webmock/minitest"

class Admin::PublishersControllerTest < ActionDispatch::IntegrationTest
  # For Devise >= 4.1.1
  include Devise::Test::IntegrationHelpers
  # Use the following instead if you are on Devise <= 4.1.0
  # include Devise::TestHelpers

  test "regular users cannot access" do
    publisher = publishers(:completed)
    sign_in publisher

    assert_raises(CanCan::AccessDenied) {
      get admin_publishers_path
    }
  end

  test "admin can access" do
    admin = publishers(:admin)
    sign_in admin

    get admin_publishers_path
    assert_response :success
  end

  test "admin filters appropriately on name & email" do
    admin = publishers(:admin)
    publisher = publishers(:completed)
    sign_in admin

    get admin_publishers_path
    assert_response :success
    assert_select 'tbody' do
      assert_select 'tr' do
        assert_select 'td', publisher.id
      end
    end

    get admin_publishers_path, params: {q: "#{publisher.name}"}
    assert_response :success
    assert_select 'tbody' do
      assert_select 'tr', true
    end

    get admin_publishers_path, params: {q: "#{publisher.name}failure"}
    assert_response :success
    assert_select 'tbody' do
      assert_select 'tr', false
    end
  end

  test "raises error unless admin has u2f enabled" do
    admin = publishers(:admin)
    admin.u2f_registrations.each { |r| r.destroy } # remove all u2f registrations
    admin.reload
    sign_in admin

    assert_raises(Ability::U2fDisabledError) do
      get admin_publishers_path
    end
  end

  test "raises error unless admin is on admin whitelist" do
    admin = publishers(:admin)
    sign_in admin

    assert_raises(Ability::AdminNotOnIPWhitelistError) do
      get admin_publishers_path, headers: { 'REMOTE_ADDR' => '1.2.3.4' } # not on whitelist
    end
  end

  test "statements created by admin have created_by_admin flag" do
    admin = publishers(:admin)
    publisher = publishers(:uphold_connected)
    sign_in admin

    prev_total_publisher_statements = PublisherStatement.count
    
    patch generate_statement_admin_publishers_path(id: publisher.id, statement_period: :past_7_days)

    # ensure a statement is created
    assert PublisherStatement.count == prev_total_publisher_statements + 1

    created_statement = PublisherStatement.order("created_at").last

    # ensure it has the created by admin flag
    assert created_statement.created_by_admin
  end
end
