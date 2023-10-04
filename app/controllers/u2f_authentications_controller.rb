# typed: ignore

class U2fAuthenticationsController < ApplicationController
  include PubTwoFactorAuth
  include Logout
  include TwoFactorRegistration

  def create
    pending_action = saved_pending_action
    publisher = pending_action.publisher
    domain = if Rails.configuration.pub_secrets[:next_proxy_url] && Rails.configuration.pub_secrets[:nextjs_enabled]
               Rails.configuration.pub_secrets[:next_proxy_url]
             else
               request.base_url
             end
    result = TwoFactorAuth::WebauthnVerifyService.build.call(publisher: publisher,
      webauthn_u2f_response: params[:webauthn_u2f_response],
      domain:  domain,
      session: session)

    case result
    when ::BSuccess
      pending_action.execute! self
    when ::BFailure
      redirect_to two_factor_authentications_path
    else
      raise result
    end
  end
end
