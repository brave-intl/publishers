# Overrides the Devise defaults for unauthenticated requests
class CustomFailureApp < Devise::FailureApp
  def redirect_url
    warden_message = warden_options[:message]
    attempted_path = warden_options[:attempted_path]
    unauthenticated = warden_options[:action] == "unauthenticated"
    has_token_claim_params = params[:token].present? && params[:id].present?

    if has_token_claim_params && unauthenticated
      if attempted_path == publisher_path(token: params[:token])
        # send publishers attempting to claim expired token to expired token page
        flash[:alert] = nil
        expired_auth_token_publishers_path(publisher_id: params[:id])
      end
    elsif warden_message == :timeout && unauthenticated
      # send publishers whose session timed out to login page
      flash[:alert] = I18n.t("publishers.devise.login_session_expired")
      new_auth_token_publishers_path
    else
      super
    end
  end

  # Override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
