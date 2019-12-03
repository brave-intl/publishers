module TwoFactorRegistration
  extend ActiveSupport::Concern

  private

  # Starting this method with `redirect_` would opt into some Rails
  # DSL, hence `handle_redirect_`.
  def handle_redirect_after_2fa_registration
    prompted_at = session[:prompted_for_two_factor_registration_at_signup]
    if prompted_at
      session.delete(:prompted_for_two_factor_registration_at_signup)
      if prompted_at > 10.minutes.ago
        flash[:modal_partial] = 'two_factor_registration_complete'
        return redirect_to home_publishers_path
      end
    end

    redirect_to security_publishers_path
  end

  def flag_2fa_registration_during_signup
    session[:prompted_for_two_factor_registration_at_signup] = Time.now
  end
end
