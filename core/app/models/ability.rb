class Ability
  include CanCan::Ability

  def user
    @user
  end

  def initialize(user=nil)
    @user=user
    
    if user
      can :update, user
    end

    define_channel_abilities
    define_fact_abilities
  end

  def define_channel_abilities
    if user
      can :index, Channel
      can :read, Channel
      can :manage, Channel do |ch|
        ch.created_by == user.graph_user
      end
    end
  end
  
  def define_fact_abilities
    can :index, Fact
    can :read, Fact
    if user
      can :opinionate, Fact
    
      can :manage, Fact do |f|
       f.created_by == user.graph_user
      end
    end
  end
  

end
