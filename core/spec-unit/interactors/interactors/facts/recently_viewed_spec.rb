require 'pavlov_helper'
require_relative '../../../../app/interactors/interactors/facts/recently_viewed.rb'

describe Interactors::Facts::RecentlyViewed do
  include PavlovSupport

  describe '.call' do
    before do
      stub_classes 'RecentlyViewedFacts', 'KillObject'
    end

    it 'calls RecentlyViewedFacts.top_facts' do
      user = mock id: '20e'
      recently_viewed_facts = mock
      fact = mock
      dead_fact = mock

      RecentlyViewedFacts.should_receive(:by_user_id).with(user.id).and_return(recently_viewed_facts)

      recently_viewed_facts.should_receive(:top_facts).with(5).and_return([fact])

      KillObject.should_receive(:fact).with(fact).and_return(dead_fact)

      result = Interactors::Facts::RecentlyViewed.new(current_user: user).call

      expect(result).to eq [dead_fact]
    end
  end
end
