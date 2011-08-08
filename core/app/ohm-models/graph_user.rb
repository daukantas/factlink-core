module UserProxy

  deprecate
  def username
    user.username
  end

  deprecate
  def username=(value)
    user.username=value
  end
end

class GraphUser < OurOhm
  include UserProxy
  
  reference :user, lambda { |id| User.find(id) }

  set :beliefs_facts, Basefact
  set :doubts_facts, Basefact
  set :disbeliefs_facts, Basefact

  collection :created_facts, Basefact, :created_by

  # Authority of the user
  def authority
    # 1.0
    Authority.for_graph_user(self)
  end

  # user.facts_he(:beliefs)
  def facts_he(type)
    self.send("#{type}_facts")
  end

  def has_opinion?(type, fact)
    facts_he(type).include?(fact)
  end

  def facts
    beliefs_facts.all + doubts_facts.all + disbeliefs_facts.all
  end
  
  def real_facts
    facts.find_all { |fact| fact.class == Fact }
  end

  def real_created_facts
    created_facts.find_all { |fact| fact.class == Fact }
  end

  def update_opinion(type, fact)
    # Remove existing opinion by user
    remove_opinions(fact)

    facts_he(type) << fact
  end

  def remove_opinions(fact)
    [:beliefs, :doubts, :disbeliefs].each do |type|
      facts_he(type).delete(fact)
    end
  end
  
end