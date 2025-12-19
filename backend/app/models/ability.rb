class Ability
  include CanCan::Ability

  def initialize(user)
    # Users can only manage their own keywords
    if user
      can :read, Keyword, user_id: user.id
      can :create, Keyword, user_id: user.id
      can :destroy, Keyword, user_id: user.id
    end
  end
end

