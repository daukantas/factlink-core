require_relative '../interactor_spec_helper'
require File.expand_path('../../../../app/interactors/commands/elastic_search_delete_topic_for_text_search.rb', __FILE__)

describe ElasticSearchDeleteTopicForTextSearch do
  def fake_class
    Class.new
  end

  let(:topic) do
    topic = stub()
    topic.stub id: 1
    topic
  end

  before do
    stub_const('HTTParty', fake_class)
    stub_const('FactlinkUI::Application', fake_class)
  end

  it 'intitializes' do
    interactor = ElasticSearchDeleteTopicForTextSearch.new topic

    interactor.should_not be_nil
  end

  it 'raises when topic is not a Topic' do
    expect { ElasticSearchDeleteTopicForTextSearch.new 'Topic' }.
      to raise_error(RuntimeError, 'topic missing fields ([:id]).')
  end

  describe '.execute' do
    it 'correctly' do
      url = 'localhost:9200'
      config = mock()
      config.stub elasticsearch_url: url
      FactlinkUI::Application.stub config: config

      HTTParty.should_receive(:delete).with("http://#{url}/topic/#{topic.id}")
      interactor = ElasticSearchDeleteTopicForTextSearch.new topic

      interactor.execute
    end
  end

end
