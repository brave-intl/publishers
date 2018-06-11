class Ability
  include CanCan::Ability
  include PublishersHelper

  ROLES = %i(admin publisher)

  def initialize(publisher)    
    @publisher = publisher || Publisher.new

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
    raise TwoFactorDisabledError.new("2fa must be enabled for administrators") unless two_factor_enabled?(@publisher)
    can :manage, :all
    can :access, :all
  end

  class TwoFactorDisabledError < RuntimeError
  end
end
