require_relative 'elastic_search_delete_for_text_search.rb'

module Commands
  class ElasticSearchDeleteTopicForTextSearch < ElasticSearchDeleteForTextSearch

    def execute
      @type_name = 'topic'
      super
    end
  end
end
