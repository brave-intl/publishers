# typed: ignore
# Sorbet doesn't recognize ApplicationController for some reason

class Oauth2Controller < ApplicationController
  # This implements a full Oauth2 Authorization Code flow
  # for any descendant of Oauth2::AuthorizationCodeBase
  # What is done on AccessTokenResponse is yet to be defined
  #
  # I had to build this just to debug the varying implementations
  # of the Oauth2::AuthorizationCodebase children.
  extend T::Sig
  include Oauth2::Responses
  include Oauth2::Errors

  before_action :set_controller_state
  before_action :set_request_state, only: [:code]

  def code
    redirect_to(client.authorization_code_url(state: @state, scope: @klass.oauth2_config.scope))
  end

  def callback
    resp = client.access_token(params.require(:code))

    case resp
    when AccessTokenResponse
      data = resp.serialize
    when ErrorResponse
      data = resp.serialize
    when UnknownError
      data = UnknownError.response
    else
      T.absurd(resp)
    end

    render json: {data: data}
  end

  private

  def client
    @_client ||= @klass.oauth2_client
  end

  # This is how state verification is typically done in an oauth2 flow
  def set_request_state
    @state = @klass.state_value!
    cookies[:_state] = {
      value: @state,
      expires: 90.seconds.from_now,
      httponly: true
    }
  end

  # TODO: Need to review this for best practices.  May need to actually encrypt the cookie with an IV
  # Also uphold does not seem to honor the cookie so it always fails.  *sigh*
  def verify_state
    raise ActionController::BadRequest if permitted_params.fetch(:state) != cookies["_state"]
  end

  def set_controller_state
    provider = permitted_params.fetch(:provider)

    case provider
    when "gemini"
      @klass = GeminiConnection
    when "uphold"
      @klass = UpholdConnection
    when "bitflyer"
      @klass = BitflyerConnection
    else
      raise ActionController::RoutingError
    end
  end

  def permitted_params
    params.permit(:provider, :state, :code)
  end
end
