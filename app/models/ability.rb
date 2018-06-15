class Ability
  include CanCan::Ability
  include PublishersHelper

  ROLES = %i(admin publisher)
  if Rails.application.secrets[:admin_ip_whitelist]
    ADMIN_IP_WHITELIST = Rails.application.secrets[:admin_ip_whitelist].split(",").map { |ip_cidr| IPAddr.new(ip_cidr) }.freeze
  else
    ADMIN_IP_WHITELIST = [].freeze
  end

  def initialize(publisher, ip)    
    @publisher = publisher || Publisher.new
    @ip = ip

    alias_action :create,   :read, :update, :destroy, to: :crud
    alias_action :read,     :create,                  to: :cr
    alias_action :destroy,  :update,                  to: :modify

    ROLES.each { |role| send(role) if @publisher.role.to_sym == role }
  end

  private

  def base_role
    can :cr,              Publisher
    can :modify,          Publisher, id: @publisher.id
  end

  def publisher
    base_role
  end

  def admin
    raise AdminNotOnIPWhitelistError.new("Administrator must be IP whitelisted") unless admin_ip_whitelisted?
    raise TwoFactorDisabledError.new("2fa must be enabled for administrators") unless two_factor_enabled?(@publisher)
    can :manage, :all
    can :access, :all
  end

  def admin_ip_whitelisted?
    return true if ADMIN_IP_WHITELIST.blank? && Rails.env.development?
    admin_ip_whitelisted = ADMIN_IP_WHITELIST.any? { |ip_addr| ip_addr.include?(@ip) }
    admin_ip_whitelisted
  end

  class TwoFactorDisabledError < RuntimeError
  end
  
  class AdminNotOnIPWhitelistError < RuntimeError
  end
end
