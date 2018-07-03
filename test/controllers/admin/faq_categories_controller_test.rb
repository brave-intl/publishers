require 'test_helper'
require "webmock/minitest"

class Admin::FaqCategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "regular users cannot access" do
    publisher = publishers(:completed)
    sign_in publisher

    assert_raises(CanCan::AccessDenied) {
      get admin_faq_categories_path
    }
  end

  test "admin can access" do
    admin = publishers(:admin)
    sign_in admin

    get admin_faq_categories_path
    assert_response :success
  end

  test "raises error unless admin has U2F enabled" do
    admin = publishers(:admin)
    admin.u2f_registrations.destroy_all # remove 2fa
    admin.reload
    sign_in admin

    assert_raises(Ability::U2fDisabledError) do
      get admin_faq_categories_path
    end
  end
end
