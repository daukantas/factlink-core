require 'pavlov_helper'
require_relative '../../../app/interactors/commands/elastic_search_index_topic_for_text_search.rb'
require 'json'

describe Commands::ElasticSearchIndexTopicForTextSearch do
  include PavlovSupport

  let(:topic) do
    topic = stub()
    topic.stub id: 1,
               title: 'title',
               slug_title: 'slug title'
    topic
  end

  before do
    stub_classes 'HTTParty', 'FactlinkUI::Application'
  end

  it 'intitializes' do
    interactor = Commands::ElasticSearchIndexTopicForTextSearch.new topic

    interactor.should_not be_nil
  end

  it 'raises when topic is not a Topic' do
    expect { interactor = Commands::ElasticSearchIndexTopicForTextSearch.new 'Topic' }.
      to raise_error(RuntimeError, 'topic missing fields ([:title, :slug_title, :id]).')
  end

  describe '.execute' do
    it 'correctly' do
      url = 'localhost:9200'
      config = mock()
      config.stub elasticsearch_url: url
      FactlinkUI::Application.stub config: config
      url = "http://#{url}/topic/#{topic.id}"
      HTTParty.should_receive(:put).with(url,
        { body: { title: topic.title, slug_title: topic.slug_title}.to_json})
      interactor = Commands::ElasticSearchIndexTopicForTextSearch.new topic

      interactor.execute
    end
  end
end
