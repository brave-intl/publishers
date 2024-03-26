# typed: ignore

class ApplicationController < ActionController::Base
  require "error_handler"
  include ErrorHandler
  include ActiveAnalyticsConcern

  protect_from_forgery prepend: true, with: :exception

  before_action :set_paper_trail_whodunnit
  before_action :no_cache
  before_action :redirect_if_suspended

  newrelic_ignore_enduser

  around_action :switch_locale

  def switch_locale(&action)
    return I18n.with_locale(I18n.default_locale, &action) if controller_path&.split("/")&.first == "admin"

    if (japanese_locale_specified? || controller_path.include?("bitflyer")) && request.get?
      # (yachtcaptain23): When we get a callback from Youtube, don't try an internal redirect and cause a CSRF token error.
      # Relates to https://github.com/brave-intl/publishers/issues/2456
      return I18n.with_locale(preferred_japanese_locale, &action) if path_is_a_callback_method?

      # Append locale=ja when it isn't given
      if japanese_locale_specified? && params[:locale].blank?
        new_url = if URI(request.original_url).query.present?
          Rails.configuration.pub_secrets[:creators_full_host] + URI(request.original_url).path + URI(request.original_url).query + "&locale=#{preferred_japanese_locale}"
        else
          Rails.configuration.pub_secrets[:creators_full_host] + URI(request.original_url).path + "?locale=#{preferred_japanese_locale}"
        end
        redirect_to(new_url, allow_other_host: true) and return
      else
        I18n.with_locale(preferred_japanese_locale, &action) and return
      end
    end

    I18n.with_locale(I18n.default_locale, &action)
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def no_cache
    return if controller_name == "static" # We want to cache on the homepage
    response.headers["Cache-Control"] = "no-cache, no-store"
  end

  def current_user
    current_publisher
  end

  def user_for_paper_trail
    current_user.try(:id)
  end

  def redirect_if_suspended
    return if !current_publisher.present?
    # publisher is neither suspended nor meets the criteria for automatic suspension
    return if current_publisher.authorized_to_act?

    # If the publisher is not suspended, then they meet the criteria for enforcing an existing  suspension
    if !current_publisher.suspended?
      current_publisher.enforce_suspension!
    end

    # The publisher is suspended at this point, thus only valid paths are relevant.
    redirect_to(suspended_error_publishers_path) and return if !request.fullpath.split("?")[0].in?(valid_suspended_paths)
  end

  def valid_suspended_paths
    [suspended_error_publishers_path.split("?")[0], log_out_publishers_path.split("?")[0]]
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, request.remote_ip, request&.headers&.fetch("HTTP_ORIGINALIP", ""))
  end

  def handle_unverified_request
    respond_to do |format|
      format.html {
        super
      }
      format.json {
        render json: {message: "Unverified request"}, status: 401
      }
    end
  end

  def u2f
    @u2f ||= U2F::U2F.new(Rails.configuration.pub_secrets[:creators_full_host])
  end

  def japanese_http_header?
    extract_locale_from_accept_language_header == "ja"
  end

  def japanese_locale_specified?
    japanese_http_header? || params[:locale] == "ja"
  end

  def path_is_a_callback_method?
    request.path.split("/").last == "callback"
  end

  def extract_locale_from_accept_language_header
    request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first
  end

  def preferred_japanese_locale
    :ja
  end
end
