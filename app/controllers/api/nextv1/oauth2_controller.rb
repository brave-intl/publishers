class Api::Nextv1::Oauth2Controller < Api::Nextv1::BaseController
  # This implements a full Oauth2 Authorization Code flow
  # for any descendant of Oauth2::AuthorizationCodeBase
  # What is done on AccessTokenResponse is yet to be defined
  #
  # I had to build this just to debug the varying implementations
  # of the Oauth2::AuthorizationCodebase children.
  include Oauth2::Responses
  include Oauth2::Errors
  before_action :set_controller_state
  before_action :set_request_state, only: [:create]

  def create
    render json: {authorization_url: authorization_url}
  end

  def debug(resp)
    data = {}
    errors = []

    case resp
    when @access_token_response
      data = resp.to_h
      @klass.create_new_connection!(current_publisher, resp)
    when ErrorResponse
      errors.push(resp.to_h)
    when UnknownError
      errors.push(resp.response.body)
    end

    render json: {data: data, errors: errors}
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

  def state_verified?
    if permitted_params.fetch(:state) != cookies.encrypted["_state"] && !@debug
      false
    else
      true
    end
  end

  def generic_error
    Oauth2::Errors::ConnectionError.new(I18n.t("shared.error"))
  end

  def record_error(result)
    LogException.perform(result, expected: true)
  end

  def allow_debug?
    Rails.env.development? && @debug
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
