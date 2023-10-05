# typed: ignore

class U2fAuthenticationsController < ApplicationController
  include PubTwoFactorAuth
  include Logout
  include TwoFactorRegistration

  def create
    pending_action = saved_pending_action
    publisher = pending_action.publisher
    result = TwoFactorAuth::WebauthnVerifyService.build.call(publisher: publisher,
      webauthn_u2f_response: params[:webauthn_u2f_response],
      domain: request.base_url,
      session: session)

    case result
    when ::BSuccess
      pending_action.execute! self
    when ::BFailure
      render json: { error: 'Unauthorized' }, status: :unauthorized
    else
      raise result
    end
  end
end
