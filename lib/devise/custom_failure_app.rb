# Overrides the Devise default for attempts to sign in with expired token
class CustomFailureApp < Devise::FailureApp
  def redirect_url
    flash[:alert] = nil
    expired_auth_token_publishers_path(publisher_id: params[:id])
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end