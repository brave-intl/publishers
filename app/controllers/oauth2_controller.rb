# typed: ignore

# Sorbet doesn't recognize ApplicationController for some reason

class Oauth2Controller < ApplicationController
  # This implements a full Oauth2 Authorization Code flow
  # for any descendant of Oauth2::AuthorizationCodeBase
  # What is done on AccessTokenResponse is yet to be defined
  #
  # I had to build this just to debug the varying implementations
  # of the Oauth2::AuthorizationCodebase children.
  include Oauth2::Responses
  include Oauth2::Errors

  before_action :authenticate_publisher!
  before_action :set_controller_state
  before_action :set_request_state, only: [:code, :create]
  before_action :set_access_token_response, only: [:callback]

  # This is just a convenience wrapper, create is not particularly explicit.
  # All a code auth request does is perform a redirect but for the sake
  # of implementation I'm just keeping the nomenclature the same for now.
  def create
    code
  end

  def code
    redirect_to(authorization_url, allow_other_host: true)
  end

  def callback
    error = nil

    if state_verified?
      # bddsec #1894 finding 21: the state cookie is single-use; clear it as
      # soon as the callback verifies so a captured callback cannot be
      # replayed within the 90-second window.
      cookies.delete(:_state)
      resp = access_token_request

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
      when Oauth2::Responses::ErrorResponse
        # Evidently log_exception needs an actual exception
        record_error(Oauth2::Errors::ConnectionError.new("Oauth2 Grant Failed with #{resp}"))
        error = generic_error
      else
        record_error(resp)
        error = generic_error
      end
    else
      record_error("Oauth2 State token invalid for publisher #{current_publisher.id} - #{@klass}")
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
