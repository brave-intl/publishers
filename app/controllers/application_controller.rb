class ApplicationController < ActionController::Base
  require "error_handler"
  include ErrorHandler

  if Rails.application.secrets[:basic_auth_user] && Rails.application.secrets[:basic_auth_password]
    http_basic_authenticate_with(
      name: Rails.application.secrets[:basic_auth_user],
      password: Rails.application.secrets[:basic_auth_password]
    )
  end

  protect_from_forgery prepend: true, with: :exception

  before_action :set_paper_trail_whodunnit
  before_action :no_cache
  before_action :redirect_if_suspended

  newrelic_ignore_enduser

  rescue_from Ability::AdminNotOnIPWhitelistError do |e|
    render "admin/errors/whitelist", layout: false
  end

  around_action :switch_locale

  def switch_locale(&action)
    return I18n.with_locale(I18n.default_locale, &action) if controller_path&.split("/")&.first == 'admin'

    if (japanese_http_header? || has_paypal_account? || controller_path.include?("bitflyer")) && request.get?
      # (yachtcaptain23): When we get a callback from Youtube, don't try an internal redirect and cause a CSRF token error.
      # Relates to https://github.com/brave-intl/publishers/issues/2456
      if (request.path.split("/").last == "callback" || japanese_http_header?)
        if params[:locale].nil?
          new_url = if URI(request.original_url).query.present?
                      request.original_url + "&locale=#{preferred_japanese_locale.to_s}"
                    else
                      request.original_url.sub(/\/*$/, "/") + "?locale=#{preferred_japanese_locale.to_s}"
                    end
          redirect_to(new_url) and return
        else
          return I18n.with_locale(preferred_japanese_locale, &action)
        end
      end
    end

    I18n.with_locale(I18n.default_locale, &action)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def no_cache
    return if controller_name == 'static' # We want to cache on the homepage
    response.headers['Cache-Control'] = 'no-cache, no-store'
  end

  def current_user
    current_publisher
  end

  def user_for_paper_trail
    current_user.try(:id)
  end

  def redirect_if_suspended
    # Redirect to suspended page if they're logged in
    redirect_to(suspended_error_publishers_path) and return if current_publisher&.suspended? && !request.fullpath.split("?")[0].in?(valid_suspended_paths)
  end

  def valid_suspended_paths
    [suspended_error_publishers_path.split("?")[0], log_out_publishers_path.split("?")[0]]
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, request.remote_ip)
  end

  def handle_unverified_request
    respond_to do |format|
      format.html {
        super
      }
      format.json {
        render json: { message: 'Unverified request' }, status: 401
      }
    end
  end

  def has_paypal_account?
    current_publisher.present? && current_publisher.paypal_connection.present?
  end

  def u2f
    @u2f ||= U2F::U2F.new(request.base_url)
  end

  def japanese_http_header?
    extract_locale_from_accept_language_header == 'ja'
  end

  def use_jabap?
    locale = params[:locale]
   (locale == 'ja' && current_user && (!current_user.bitflyer_enabled? || current_user.selected_wallet_provider_type == "PaypalConnection")) || locale == 'jabap'
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
  end

  def preferred_japanese_locale
    use_jabap? ? :jabap : :ja
  end
end
