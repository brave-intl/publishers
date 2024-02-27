# typed: ignore

class Ability
  include CanCan::Ability
  include PublishersHelper

  ROLES = %i[admin publisher].freeze
  ADMIN_IP_WHITELIST = if Rails.configuration.pub_secrets[:admin_ip_whitelist]
    Rails.configuration.pub_secrets[:admin_ip_whitelist].split(",").map { |ip_cidr| IPAddr.new(ip_cidr) }.freeze
  else
    [].freeze
  end

  def initialize(publisher, ip, forwarded_ip = "")
    @publisher = publisher || Publisher.new
    @ip = ip
    # Might come in as "HTTP_ORIGINALIP"=>"1.3.1.13, 13.45.54.81",
    @forwarded_ip = forwarded_ip.split(",").map(&:strip)

    alias_action :create, :read, :update, :destroy, to: :crud
    alias_action :read, :create, to: :cr
    alias_action :destroy, :update, to: :modify

    ROLES.each { |role| send(role) if @publisher.role.to_sym == role }
  end

  private

  def base_role
    can :cr, Publisher
    can :modify, Publisher, id: @publisher.id
  end

  def publisher
    base_role
  end

  def admin
    raise AdminNotOnIPWhitelistError, "Administrator must be IP whitelisted" unless admin_ip_whitelisted?
    if Rails.env.production? || Rails.env.test?
      raise U2fDisabledError, "U2F must be enabled for administrators" unless u2f_enabled?(@publisher)
    end
    can :manage, :all
    can :access, :all
  end

  def admin_ip_whitelisted?
    return true if ADMIN_IP_WHITELIST.blank? && (Rails.env.development? || Rails.env.test?)
    ADMIN_IP_WHITELIST.any? { |ip_addr| ip_addr.include?(@ip) || (!@forwarded_ip.blank? && @forwarded_ip.any? { |fip| ip_addr.include?(fip) }) }
  end

  class U2fDisabledError < RuntimeError
  end

  class AdminNotOnIPWhitelistError < RuntimeError
  end
end
