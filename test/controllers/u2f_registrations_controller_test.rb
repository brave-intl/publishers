require "test_helper"

class U2fRegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def canned_u2f_response
    return ActiveSupport::JSON.encode({
      registrationData: "BQSM6EVrCw0w-PctTplo08E-Fsv567-cM5cEAaOwy4D_FX04ydGc7se5g6UzpgLGfmTn142VGOWPfN62RAPgxfXqQF3cRU0FNxZec4Mn6JMgkf8sKixGtH8Zj7-u2kllPxfmxZHVKSgGuotS4dyykc2Puf-30FKWuGTGxhK5HgUT-LswggJKMIIBMqADAgECAgRXFvfAMA0GCSqGSIb3DQEBCwUAMC4xLDAqBgNVBAMTI1l1YmljbyBVMkYgUm9vdCBDQSBTZXJpYWwgNDU3MjAwNjMxMCAXDTE0MDgwMTAwMDAwMFoYDzIwNTAwOTA0MDAwMDAwWjAsMSowKAYDVQQDDCFZdWJpY28gVTJGIEVFIFNlcmlhbCAyNTA1NjkyMjYxNzYwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARk2RxU1tlXjdOwYHhMRjbVSKOYOq81J87rLcbjK2eeM_zp6GMUrbz4V1IbL0xJn5SvcFVlviIZWym2Tk2tDdBiozswOTAiBgkrBgEEAYLECgIEFTEuMy42LjEuNC4xLjQxNDgyLjEuNTATBgsrBgEEAYLlHAIBAQQEAwIFIDANBgkqhkiG9w0BAQsFAAOCAQEAeJsYypuk23Yg4viLjP3pUSZtKiJ31eP76baMmqDpGmpI6nVM7wveWYQDba5_i6P95ktRdgTDoRsubXVNSjcZ76h2kw-g4PMGP1pMoLygMU9_BaPqXU7dkdNKZrVdXI-obgDnv1_dgCN-s9uCPjTjEmezSarHnCSnEqWegEqqjWupJSaid6dx3jFqc788cR_FTSJmJ_rXleT0ThtwA08J_P44t94peJP7WayLHDPPxca-XY5Mwn9KH0b2-ET4eMByi9wd-6Zx2hCH9Yzjjllro_Kf0FlBXcUKoy-JFHzT2wgBN9TmW7zrC7_lQYgYjswUMRh5UZKrOnOHqaVyfxBIhjBFAiEAzu8YCpqP1z6N99lihFuzs_56EThtxm5tMYQmoCBLNdUCIDHfgiU3Sdu82ZwYTWz_oV9VpgvBtAQdPDOmQCNsLXvC",
      version: "U2F_V2",
      challenge: "4DXURTQ3_1pzkPTYqSAQeb4TOnaiN4L5Td2dQpnn7nY",
      clientData: "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIsImNoYWxsZW5nZSI6IjREWFVSVFEzXzFwemtQVFlxU0FRZWI0VE9uYWlONEw1VGQyZFFwbm43blkiLCJvcmlnaW4iOiJodHRwczovL2xvY2FsaG9zdDozMDAwIiwiY2lkX3B1YmtleSI6InVudXNlZCJ9"
    })
  end

  test "new requires authentication" do
    get new_u2f_registration_path

    assert_redirected_to root_path
  end

  test "new renders when authenticated with new key form" do
    sign_in publishers(:verified)
    get new_u2f_registration_path

    assert_response :success
    assert_select "form[method=post][action=?]", u2f_registrations_path do
      assert_select "input[name='u2f_registration[name]']:not([value])"
      assert_select "input[name=u2f_app_id][value=?]", @controller.u2f.app_id
      # Check that registration_requests has JSON array value
      assert_select "input[name=u2f_registration_requests][value^='[']"
      assert_select "input[name=u2f_sign_requests][value^='[']"
      # Check that response field is provided but not assigned a value
      assert_select "input[name=u2f_response]:not([value])"
      assert_select "input[type=submit]"
    end
  end

  test "U2F registration creation" do
    sign_in publishers(:verified)

    mock_u2f_registration = stub(
      certificate: "cert",
      key_handle: "handle",
      public_key: "sdf",
      counter: 1
    )
    U2fRegistrationsController.any_instance.stubs(:u2f).returns(mock(:register! => mock_u2f_registration))

    assert_difference("U2fRegistration.count") do
      post u2f_registrations_path, params: {
        u2f_registration: { name: "Name" },
        u2f_response: canned_u2f_response
      }
    end

    assert_redirected_to two_factor_registrations_path, "redirects to two_factor_registrations"
  end

  test "index renders a registered key" do
    publisher = publishers(:completed)
    u2f_registration = u2f_registrations(:default)
    publisher.u2f_registrations << u2f_registration

    sign_in publisher
    get two_factor_registrations_path

    assert_response :success
    assert_match u2f_registration.name, response.body
    assert_match /Set up an authenticator as\sthe secondary 2FA/, response.body
    assert_select "a[data-method=delete][href=?]", u2f_registration_path(u2f_registration)
  end

  test "index renders many registered keys" do
    publisher = publishers(:completed)

    u2f_registration = u2f_registrations(:default)
    publisher.u2f_registrations << u2f_registration

    additional_u2f_registration = u2f_registrations(:additional)
    publisher.u2f_registrations << additional_u2f_registration

    sign_in publisher
    get two_factor_registrations_path

    assert_response :success
    assert_match u2f_registration.name, response.body
    assert_match additional_u2f_registration.name, response.body
    assert_match "Authenticator app has not been set up", response.body
    assert_select "a[data-method=delete][href=?]", u2f_registration_path(u2f_registration)
    assert_select "a[data-method=delete][href=?]", u2f_registration_path(additional_u2f_registration)
  end

  test "delete removes registered key" do
    publisher = publishers(:verified)
    u2f_registration = u2f_registrations(:default)
    publisher.u2f_registrations << u2f_registration

    sign_in publisher
    delete u2f_registration_path(u2f_registration)

    assert_redirected_to two_factor_registrations_path, "redirects to two_factor_registrations"
    follow_redirect!
    assert_response :success
    assert_no_match u2f_registration.name, response.body, "page does not show deleted u2f_registration"
  end
end
