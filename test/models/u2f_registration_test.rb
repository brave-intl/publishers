require 'test_helper'

class U2fRegistrationTest < ActiveSupport::TestCase
  test "U2f Registration belongs to a Publisher" do
    registration = u2f_registrations(:default)
    assert_instance_of Publisher, registration.publisher
  end
end
