class CustomFailure < Devise::FailureApp
    def redirect_url
      flash[:alert] = nil
      expired_auth_token_publishers_path
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