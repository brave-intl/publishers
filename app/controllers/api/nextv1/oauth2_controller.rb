class Api::Nextv1::Oauth2Controller < Api::Nextv1::BaseController
  include Oauth2::Responses
  include Oauth2::Errors

  before_action :set_controller_state
  before_action :set_request_state, only: [:create]

  def create
    render json: {authorization_url: authorization_url}
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
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production? || Rails.env.staging?
    }
  end

  def state_verified?
    # bddsec #1894 follow-up: an empty cookie and an empty state param
    # compared equal, letting attacker callbacks bypass the state guard on
    # creators with no prior connection flow. Both values must be present.
    cookie_state = cookies.encrypted["_state"]
    return false if cookie_state.blank?
    return false if permitted_params[:state].blank?

    ActiveSupport::SecurityUtils.secure_compare(
      permitted_params[:state].to_s,
      cookie_state.to_s
    )
  end

  def generic_error
    Oauth2::Errors::ConnectionError.new(I18n.t("shared.error"))
  end

  def record_error(result)
    LogException.perform(result, expected: true)
  end

  # Note: To use this as a subclass you'll want to override this method entirely
  # and just set whatever the relevant @klass is.
  def set_controller_state
    provider = permitted_params.fetch(:provider)

    case provider
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
