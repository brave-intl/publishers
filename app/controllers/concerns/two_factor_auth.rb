module TwoFactorAuth
  extend ActiveSupport::Concern

  included do
    include PublishersHelper

    before_action :require_pending_2fa_current_publisher
  end

  private

  def pending_2fa_current_publisher
    Publisher.find(session[:pending_2fa_current_publisher_id])
  end

  def require_pending_2fa_current_publisher
    if ! session[:pending_2fa_current_publisher_id]
      redirect_to root_path
    end
  end
end
