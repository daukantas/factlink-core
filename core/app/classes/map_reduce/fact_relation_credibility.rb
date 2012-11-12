class MapReduce
  class FactRelationCredibility < MapReduce
    def initialize
      @fact_authorities = {}
    end

    def all_set
      FactRelation.all
    end

    def authorities_on_fact_id(fact_id)
      @fact_authorities[fact_id] ||= Authority.all_on(Basefact[fact_id])
    end

    def map iterator
      iterator.each do |fact_relation|
        authorities_on_fact_id(fact_relation.fact_id).each do |a|
          yield({fact_id: fact_relation.id, user_id: a.user_id}, a.to_f)
        end
      end
    end

    def reduce bucket, authorities
      authorities.inject(0,:+) / authorities.size
    end

    def write_output bucket, value
      f = Basefact[bucket[:fact_id]]
      gu = GraphUser[bucket[:user_id]]
      if f and gu
        Authority.on(f, for: gu) << value
      end
    end
  end
end
