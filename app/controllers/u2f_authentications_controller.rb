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
    if result.success?
      sign_in(:publisher, publisher)
      redirect_to publisher_next_step_path(publisher)
    else
      redirect_to two_factor_authentications_path
    end
  end
end
