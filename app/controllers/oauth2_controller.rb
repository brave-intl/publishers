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
  before_action :set_access_token_response, only: [:callback]

  # This is just a convenience wrapper, create is not particularly explicit.
  # All a code auth request does is perform a redirect but for the sake
  # of implementation I'm just keeping the nomenclature the same for now.
  def create
    code
  end

  def code
    redirect_to(authorization_url)
  end

  def debug(resp)
    data = {}
    errors = []

    case resp
    when @access_token_response
      data = resp.serialize
      @klass.create_new_connection!(current_publisher, resp)
    when ErrorResponse
      errors.push(resp.serialize)
    when UnknownError
      errors.push(resp.response.body)
    end

    render json: {data: data, errors: errors}
  end

  def callback
    resp = access_token_request

    if allow_debug?
      debug(resp) and return
    end

    error = nil

    case resp
    when @access_token_response
      begin
        @klass.create_new_connection!(current_publisher, resp)
      rescue => e
        record_error(e)
        error = case e
        when Oauth2::Errors::ConnectionError # Use known messages for error flashes
          e
        else
          generic_error
        end
      end
    else
      record_error(resp)
      error = generic_error
    end

    kwargs = error.present? ? {flash: {alert: error.message}} : {}
    redirect_to(home_publishers_path, **kwargs)
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

  def verify_state
    raise ActionController::BadRequest if permitted_params.fetch(:state) != cookies.encrypted["_state"] && !@debug
  end

  def set_access_token_response
    # This will be correct in most oauth2 cases, but
    # I'm keeping open the opportunity to easily override this
    # when needed.
    if @access_token_response.nil?
      @access_token_response = AccessTokenResponse
    end
  end

  def generic_error
    Oauth2::Errors::ConnectionError.new(I18n.t("shared.error"))
  end

  def record_error(result)
    LogException.perform(result, publisher: current_publisher)
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
