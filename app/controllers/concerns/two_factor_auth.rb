# typed: ignore
module TwoFactorAuth
  extend ActiveSupport::Concern

  included do
    include PublishersHelper
    include PendingActions

    before_action :require_pending_action
  end

  private

  def require_pending_action
    if !session[:pending_action]
      redirect_to root_path
    end
  end
end
