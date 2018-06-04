class Ability
  include CanCan::Ability

  ROLES = %i(admin publisher)

  def initialize(publisher)
    @publisher = publisher || Publisher.new

    alias_action :create,   :read, :update, :destroy, to: :crud
    alias_action :read,     :create,                  to: :cr
    alias_action :destroy,  :update,                  to: :modify

    ROLES.each { |role| send(role) if @publisher.kind.to_sym == role }
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
    can :manage, :all
    can :access, :all
  end
end
