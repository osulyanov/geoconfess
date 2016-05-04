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

      can :read, Spot
      if user.priest?
        can :create, Spot
        can :update, Spot, priest_id: user.id
        can :destroy, Spot, priest_id: user.id
      end

      can :read, Recurrence
      can :update, Recurrence do |recurrence|
        recurrence.spot.priest_id == user.id
      end
      can :destroy, Recurrence do |recurrence|
        recurrence.spot.priest_id == user.id
      end
      can :create, Recurrence if user.priest?
      can :for_priest, Recurrence
      can :confirm_availability, Recurrence if user.priest?

      can :create, Message
      can :read, Message do |request|
        request.sender_id == user.id || request.recipient_id == user.id
      end
      can :update, Message do |request|
        request.sender_id == user.id || request.recipient_id == user.id
      end
      can :destroy, Message do |request|
        request.sender_id == user.id || request.recipient_id == user.id
      end

      can :read, Notification, user_id: user.id
      can :mark_read, Notification, user_id: user.id
      can :mark_sent, Notification, user_id: user.id

      can :crud, Favorite, user_id: user.id
    end
  end
end
