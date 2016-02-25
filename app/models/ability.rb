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

      can :create, MeetRequest
      can :read, MeetRequest do |request|
        request.priest_id == user.id || request.penitent_id == user.id
      end
      can :update, MeetRequest, priest_id: user.id
      can :destroy, MeetRequest, priest_id: user.id
      can :accept, MeetRequest, priest_id: user.id
      can :refuse, MeetRequest, priest_id: user.id

      can :create, Church if user.priest?
      can :read, Church

      can :read, Spot
      if user.priest?
        can :create, Spot
        can :update, Spot, priest_id: user.id
        can :destroy, Spot, priest_id: user.id
      end
    end
  end
end
