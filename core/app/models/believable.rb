class Believable
  attr_reader :key
  def initialize key
    @key = key
  end

  def votes
    {
      believes: opiniated_key(:believes).scard,
      disbelieves: opiniated_key(:disbelieves).scard
    }
  end

  def opinion_of_graph_user_id graph_user_id
    OpinionType.types.each do |opinion|
      return opinion if opiniated_key(opinion).sismember graph_user_id
    end
    return :no_vote
  end

  def opinionated_users_ids
    opiniated_key(:believes).smembers +
      opiniated_key(:disbelieves).smembers
  end

  def add_opiniated_id(type, graph_user_id)
    remove_opinionated_id graph_user_id
    opiniated_key(type).sadd graph_user_id
  end

  def remove_opinionated_id(graph_user_id)
    OpinionType.types.each do |type|
      opiniated_key(type).srem graph_user_id
    end
  end

  def delete
    opiniated_key(:believes).del
    opiniated_key(:disbelieves).del
  end

  def opiniated_ids(type)
    opiniated_key(type).smembers
  end

  private def opiniated_key(type)
    fail 'Unknown opinion type' unless OpinionType.include?(type.to_s)

    key["people_#{type.to_s}"]
  end
end
