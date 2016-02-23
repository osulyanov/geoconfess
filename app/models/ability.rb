class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud
    user ||= User.new
    if user.admin?
      can :manage, :all
    else
      can :update, User, id: user.id
      cannot :activate, User
      cannot :deactivate, User
    end
  end
end
