# typed: ignore
require "concerns/two_factor_auth"

class U2fAuthenticationsController < ApplicationController
  include TwoFactorAuth

  def create
    publisher = pending_2fa_current_publisher
    result = TwoFactorAuth::WebauthnVerifyService.build.call(publisher: publisher,
      webauthn_u2f_response: params[:webauthn_u2f_response],
      domain: request.base_url,
      session: session)

    case result
    when ::BSuccess
      sign_in(:publisher, publisher)
      redirect_to publisher_next_step_path(publisher)
    when ::BFailure
      redirect_to two_factor_authentications_path
    else
      T.absurd(result)
    end
  end
end
