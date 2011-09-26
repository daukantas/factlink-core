class Fact < Basefact
  #include FactDataProxy
  
  after :create, :set_activity!

  def set_activity!
    activity(self.created_by, "created", self)
  end

  def to_s
    self.data.displaystring || ""
  end

  reference :site, Site       # The site on which the factlink should be shown
  def url=(url)
    self.site = Site.find_or_create_by(:url => url)
  end
  def url
    self.site.url
  end
  # Return a nice looking url, only subdomain + domain + top level domain
  def pretty_url #TODO move to helper function, has no place in the model
    self.site.url.gsub(/http(s?):\/\//,'').split('/')[0]
  end

  reference :data, lambda { |id| FactData.find(id) }
  
  def require_data # dit ook doen met zo'n aftercreategebeuren    
    if not self.data_id
      localdata = FactData.new
      localdata.save    # FactData now has an ID
      self.data = localdata
      if self.save
        localdata.fact_id = self.id
        localdata.save
      else
        raise StandardException, "the object could not be saved, but this is required before a require_data can be executed"
      end
    end
  end
  
  def require_saved_data
    if not self.data_id
      localdata = FactData.new
      localdata.save    # FactData now has an ID
      self.data = localdata
    end
  end

  def set_own_id_on_saved_data
    self.data.fact_id = self.id
    self.data.save
  end
  
  before :save, :require_saved_data
  after :save, :set_own_id_on_saved_data


  set :supporting_facts, FactRelation
  set :weakening_facts, FactRelation

  def evidenced_factrelations
    FactRelation.find(:from_fact_id => self.id).all
  end
  
  def evidenced_facts
    evidenced_factrelations.map{|f| f.fact }
  end
  
  def self.by_display_string(displaystring)
    fd = FactData.where(:displaystring => displaystring)
    if fd.count > 0
      fd.first.fact
    else
      nil
    end
  end
  
  # OHm Model needs to have a definition of which fields to render
  def to_hash
    super.merge(:_id => id, :displaystring => self.data.displaystring, :score_dict_as_percentage => get_opinion.as_percentages)
  end
  
  deprecate
  def fact_relations_ids
    fact_relations.map { |fr| fr.id }
  end
  
  def fact_relations
    supporting_facts | weakening_facts
  end
  
  def sorted_fact_relations
    res = self.fact_relations.sort { |a, b| a.percentage <=> b.percentage }
    res.reverse
  end
  
  def evidence(type)
    case type
    when :supporting
      return self.supporting_facts
    when :weakening
      return self.weakening_facts
    end
    puts "Fact#evidence -- No evidence found for type '#{type}'"
  end

  def add_evidence(type, evidence, user)
    # Some extra loop protection
    if evidence.id == self.id
      puts "[ERROR] Fact#add_evidence -- Failed creating a FactRelation because that would cause a loop!"
      return nil
    else
      fr = FactRelation.get_or_create(evidence,type,self,user)
      activity(user,:created,fr)
      fr
    end
  end
  
  # Count helpers
  def supporting_evidence_count
    evidence(:supporting).size
  end

  def weakening_evidence_count
    evidence(:weakening).size
  end

  def evidence_count
    weakening_evidence_count + supporting_evidence_count
  end
  
  # Used for sorting
  #deprecate
  def self.column_names
    FactData.column_names
  end

  
  def delete
    delete_from_channels
    delete_all_evidence
    delete_all_evidenced
    data.delete
    super
  end
  alias :delete_cascading :delete
  
  def delete_all_evidence
    fact_relations.each do |fr|
      fr.delete
    end
  end
  
  def delete_all_evidenced
    FactRelation.find(:from_fact_id => self.id).each do |fr|
      fr.delete
    end
  end

  def delete_from_channels
    #TODO actually do this properly
    Channel.all.each do |ch|
      ch.remove_fact(self)
    end
  end
  
  
  
  private :delete_all_evidence, :delete_all_evidenced

  value_reference :evidence_opinion, Opinion
  def calculate_evidence_opinion(depth=0)
    opinions = []
    [:supporting, :weakening].each do |type|
      factrelations = evidence(type)
      factrelations.each do |factrelation|
        opinions << factrelation.get_influencing_opinion(depth-1)
      end
    end
    self.evidence_opinion = Opinion.combine(opinions)
    save
  end
  def get_evidence_opinion(depth=0)
    if depth > 0
      self.calculate_evidence_opinion(depth)
    end
    self.evidence_opinion || Opinion.identity
  end

  value_reference :opinion, Opinion
  def calculate_opinion(depth=0)
    calculate_evidence_opinion
    total_opinion = self.get_user_opinion(depth) + self.get_evidence_opinion(depth)
    self.opinion = total_opinion
    save
  end
  def get_opinion(depth=0)
    if depth > 0
      self.calculate_opinion(depth)
    end    
    self.opinion || Opinion.identity
  end

  attribute :cached_incluencing_authority
  def calculate_influencing_authority
    self.cached_incluencing_authority = [1, FactRelation.find(:from_fact_id => self.id).except(:created_by_id => self.created_by_id).count].max
    self.save
  end
  def influencing_authority
    self.cached_incluencing_authority.to_i || 1.0
  end
  
end
