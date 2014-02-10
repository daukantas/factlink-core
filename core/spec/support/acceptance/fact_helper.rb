module Acceptance
  module FactHelper
    include ::FactHelper

    def go_to_discussion_page_of factlink
      visit friendly_fact_path factlink
      find('.spec-button-believes')
    end

    def go_to_fact_show_of factlink
      visit "/client/facts/#{factlink.id}"
    end

    def backend_create_fact
      create :fact
    end

    def backend_create_fact_with_long_text
      fact_data = create :fact_data, displaystring: 'long'*30
      create :fact, data: fact_data
    end

    def click_agree fact, user
      find('.spec-button-believes').click


      eventually_succeeds do
        expect(fact.believable.opinion_of_graph_user(user.graph_user)).to eq "believes"
      end
    end
  end
end
