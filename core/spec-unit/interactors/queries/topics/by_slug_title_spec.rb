require 'pavlov_helper'
require_relative '../../../../app/interactors/queries/topics/by_slug_title'

describe Queries::Topics::BySlugTitle do
  include PavlovSupport

  describe 'execute' do
    it 'returns the topic Topic.by_slug' do
      stub_classes 'Topic'

      slug_title = 'foo'
      topic = double

      Topic.should_receive(:by_slug).with(slug_title).and_return(topic)

      query = described_class.new slug_title: slug_title

      result = query.execute
      expect(result).to eq topic
    end
  end
end
