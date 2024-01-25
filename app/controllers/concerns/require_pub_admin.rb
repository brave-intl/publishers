module RequirePubAdmin
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied do |_|
      render "admin/errors/not_authorized", layout: false
    end

    rescue_from Ability::AdminNotOnIPWhitelistError do |_|
      render "admin/errors/whitelist", layout: false
    end

    before_action :require_pub_admin
  end

  private

  def require_pub_admin
    authorize! :access, :admin
  end
end
