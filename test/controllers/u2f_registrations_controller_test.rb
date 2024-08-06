# typed: false

require "test_helper"

class U2fRegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include MockRewardsResponses

  before do
    stub_rewards_parameters
  end

  def canned_u2f_response
    ActiveSupport::JSON.encode({
      registrationData: "BQSM6EVrCw0w-PctTplo08E-Fsv567-cM5cEAaOwy4D_FX04ydGc7se5g6UzpgLGfmTn142VGOWPfN62RAPgxfXqQF3cRU0FNxZec4Mn6JMgkf8sKixGtH8Zj7-u2kllPxfmxZHVKSgGuotS4dyykc2Puf-30FKWuGTGxhK5HgUT-LswggJKMIIBMqADAgECAgRXFvfAMA0GCSqGSIb3DQEBCwUAMC4xLDAqBgNVBAMTI1l1YmljbyBVMkYgUm9vdCBDQSBTZXJpYWwgNDU3MjAwNjMxMCAXDTE0MDgwMTAwMDAwMFoYDzIwNTAwOTA0MDAwMDAwWjAsMSowKAYDVQQDDCFZdWJpY28gVTJGIEVFIFNlcmlhbCAyNTA1NjkyMjYxNzYwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARk2RxU1tlXjdOwYHhMRjbVSKOYOq81J87rLcbjK2eeM_zp6GMUrbz4V1IbL0xJn5SvcFVlviIZWym2Tk2tDdBiozswOTAiBgkrBgEEAYLECgIEFTEuMy42LjEuNC4xLjQxNDgyLjEuNTATBgsrBgEEAYLlHAIBAQQEAwIFIDANBgkqhkiG9w0BAQsFAAOCAQEAeJsYypuk23Yg4viLjP3pUSZtKiJ31eP76baMmqDpGmpI6nVM7wveWYQDba5_i6P95ktRdgTDoRsubXVNSjcZ76h2kw-g4PMGP1pMoLygMU9_BaPqXU7dkdNKZrVdXI-obgDnv1_dgCN-s9uCPjTjEmezSarHnCSnEqWegEqqjWupJSaid6dx3jFqc788cR_FTSJmJ_rXleT0ThtwA08J_P44t94peJP7WayLHDPPxca-XY5Mwn9KH0b2-ET4eMByi9wd-6Zx2hCH9Yzjjllro_Kf0FlBXcUKoy-JFHzT2wgBN9TmW7zrC7_lQYgYjswUMRh5UZKrOnOHqaVyfxBIhjBFAiEAzu8YCpqP1z6N99lihFuzs_56EThtxm5tMYQmoCBLNdUCIDHfgiU3Sdu82ZwYTWz_oV9VpgvBtAQdPDOmQCNsLXvC",
      version: "U2F_V2",
      challenge: "4DXURTQ3_1pzkPTYqSAQeb4TOnaiN4L5Td2dQpnn7nY",
      clientData: "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIsImNoYWxsZW5nZSI6IjREWFVSVFEzXzFwemtQVFlxU0FRZWI0VE9uYWlONEw1VGQyZFFwbm43blkiLCJvcmlnaW4iOiJodHRwczovL2xvY2FsaG9zdDozMDAwIiwiY2lkX3B1YmtleSI6InVudXNlZCJ9"
    })
  end

  def canned_u2f_response2(registration)
    ActiveSupport::JSON.encode({
      keyHandle: registration.key_handle,
      clientData: "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiMEVxTHk3TExoYWQyVVN1Wk9ScWRqZThsdG9VWHZQVUU5aHQyRU5sZ2N5VSIsIm9yaWdpbiI6Imh0dHBzOi8vbG9jYWxob3N0OjMwMDAiLCJjaWRfcHVia2V5IjoidW51c2VkIn0",
      signatureData: "AQAAAAowRQIgfFLvGl1joGFlmZKPgIkimfJGt5glVEdiUYDtF8olMJgCIQCHIMR9ofM7VE7U6xURkDce8boCHwLq-vyVB9rWcKcscQ"
    })
  end

  test "new requires authentication" do
    get new_u2f_registration_path

    assert_redirected_to root_path
  end

  test "U2F registration creation" do
    publisher = publishers(:verified)
    u2f_registration = u2f_registrations(:default)

    publisher.u2f_registrations << u2f_registration

    sign_in publisher

    TwoFactorAuth::WebauthnRegistrationService.any_instance.stubs(:call).returns(success_struct_empty)
    TwoFactorAuth::WebauthnVerifyService.any_instance.stubs(:call).returns(success_struct_empty)

    post u2f_registrations_path, params: {
      u2f_registration: {name: "Name"},
      u2f_response: canned_u2f_response
    }

    assert_redirected_to controller: "two_factor_authentications"

    post u2f_authentications_path, params: {
      u2f_response: canned_u2f_response2(u2f_registration)
    }

    assert_redirected_to controller: "/publishers/security", action: "index"

    refute @request.flash[:modal_partial]
  end

  test "U2F registration creation after prompt" do
    publisher = publishers(:verified)
    u2f_registration = u2f_registrations(:default)
    publisher.u2f_registrations << u2f_registration

    sign_in publisher

    TwoFactorAuth::WebauthnRegistrationService.any_instance.stubs(:call).returns(success_struct_empty)
    TwoFactorAuth::WebauthnVerifyService.any_instance.stubs(:call).returns(success_struct_empty)

    get prompt_security_publishers_path

    post u2f_registrations_path, params: {
      u2f_registration: {name: "Name"},
      u2f_response: canned_u2f_response
    }

    assert_redirected_to controller: "two_factor_authentications"

    post u2f_authentications_path, params: {
      u2f_response: canned_u2f_response2(u2f_registration)
    }

    assert_redirected_to controller: "/publishers", action: "home"
    assert @request.flash[:modal_partial]

    follow_redirect!

    assert_select "#js-open-modal-on-load"
  end

  test "delete removes registered key" do
    publisher = publishers(:verified)
    u2f_registration = u2f_registrations(:default)
    publisher.u2f_registrations << u2f_registration

    sign_in publisher
    delete u2f_registration_path(u2f_registration)

    assert_redirected_to controller: "two_factor_authentications"
    follow_redirect!

    TwoFactorAuth::WebauthnRegistrationService.any_instance.stubs(:call).returns(success_struct_empty)
    TwoFactorAuth::WebauthnVerifyService.any_instance.stubs(:call).returns(success_struct_empty)

    post u2f_authentications_path, params: {
      u2f_response: canned_u2f_response2(u2f_registration)
    }

    assert_redirected_to controller: "/publishers/security", action: "index"

    follow_redirect!
    assert_response :success
    assert_no_match u2f_registration.name, response.body, "page does not show deleted u2f_registration"
  end

  test "logout everybody else on registration" do
    publisher = publishers(:verified)
    u2f_registration = u2f_registrations(:default)
    publisher.u2f_registrations << u2f_registration

    sign_in publisher
    another_session = open_session
    another_session.sign_in publisher

    TwoFactorAuth::WebauthnRegistrationService.any_instance.stubs(:call).returns(success_struct_empty)
    TwoFactorAuth::WebauthnVerifyService.any_instance.stubs(:call).returns(success_struct_empty)

    post u2f_registrations_path, params: {
      u2f_registration: {name: "Name"},
      u2f_response: canned_u2f_response
    }

    assert_redirected_to controller: "two_factor_authentications"

    post u2f_authentications_path, params: {
      u2f_response: canned_u2f_response2(u2f_registration)
    }

    assert_redirected_to controller: "/publishers/security", action: "index"
    refute @request.flash[:modal_partial]

    another_session.get "/publishers/security"
    another_session.assert_redirected_to root_path # logout redirects to root
  end
end
