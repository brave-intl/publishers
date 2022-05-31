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
  before_action :authenticate_publisher!
  before_action :set_controller_state
  before_action :set_request_state, only: [:code, :create]
  before_action :verify_state, only: [:callback]

  # This is just a convenience wrapper, create is not particularly explicit.
  # All a code auth request does is perform a redirect but for the sake
  # of implementation I'm just keeping the nomenclature the same for now.
  def create
    code
  end

  def code
    redirect_to(authorization_url)
  end

  def callback
    resp = access_token_request

    case resp
    when AccessTokenResponse
      data = resp.serialize
      @klass.create_new_connection!(current_publisher, resp)
    when ErrorResponse
      data = resp.serialize
    when UnknownError
      data = resp.response.body
    else
      T.absurd(resp)
    end

    if @debug
      render json: {data: data} and return
    else
      redirect_to(home_publishers_path)
    end
  end

  private

  # This is set as a method to allow for individual overrides
  # Bitflyer for example uses the code challenge verification mechanism which is not
  # in wide use (though adds additional laters of security.
  def access_token_request
    client.access_token(params.require(:code))
  end

  # This is also abstracted so it can be easily overridde for the same reaasons listed above.
  def authorization_url
    @_authorization_url ||= client.authorization_code_url(state: @state, scope: @klass.oauth2_config.scope)
  end

  def client
    @_client ||= @klass.oauth2_client
  end

  def set_request_state
    @state = @klass.state_value!
    cookies.encrypted[:_state] = {
      value: @state,
      expires: 90.seconds.from_now,
      httponly: true
    }
  end

  # TODO: Uphold doesn't allow this.
  def verify_state
    raise ActionController::BadRequest if permitted_params.fetch(:state) != cookies.encrypted["_state"] && !@debug
  end

  # Note: To use this as a subclass you'll want to override this method entirely
  # and just set whatever the relevant @klass is.
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
