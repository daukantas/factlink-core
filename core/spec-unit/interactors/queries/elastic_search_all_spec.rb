require 'pavlov_helper'
require_relative '../../../app/interactors/queries/elastic_search_all.rb'

describe Queries::ElasticSearchAll do
  include PavlovSupport

  before do
    stub_classes 'HTTParty', 'FactData', 'User',
      'FactlinkUI::Application', 'FactlinkUser'
  end

  it 'intializes correctly' do
    query = Queries::ElasticSearchAll.new 'interesting search keywords', 1, 20

    query.should_not be_nil
  end

  describe '#call' do
    ['user', 'factdata'].each do |type|
      it "correctly with return value of #{type} class" do
        config = double
        base_url = '1.0.0.0:4000/index'
        config.stub elasticsearch_url: base_url
        FactlinkUI::Application.stub config: config
        keywords = 'searching for this channel'
        wildcard_keywords = '(searching*%20OR%20searching)+(for*%20OR%20for)+(this*%20OR%20this)+(channel*%20OR%20channel)'
        interactor = Queries::ElasticSearchAll.new keywords, 1, 20

        hit = double
        hit.should_receive(:[]).with('_id').and_return(1)
        hit.should_receive(:[]).with('_type').and_return(type)

        results = double
        results.stub code: 200
        results.stub parsed_response: { 'hits' => { 'hits' => [hit] } }

        HTTParty.should_receive(:get).
          with("http://#{base_url}/factdata,topic,user/_search?q=(searching*+OR+searching)+AND+(for*+OR+for)+AND+(this*+OR+this)+AND+(channel*+OR+channel)&from=0&size=20&analyze_wildcard=true").
          and_return(results)

        return_object = double

        case type
        when 'user'
          user_mock_id = double
          mongoid_user = mock(id: user_mock_id)
          User.should_receive(:find).
            with(1).
            and_return(mongoid_user)
          FactlinkUser.should_receive(:map_from_mongoid)
            .with(mongoid_user)
            .and_return(return_object)
        when 'topic'
          fail 'We test topics in elastic_search_channel_spec'
        when 'factdata'
          FactData.should_receive(:find).
            with(1).
            and_return(return_object)
        end

        interactor.call.should eq [return_object]
      end
    end

    it 'logs and raises an error when HTTParty returns a non 2xx status code.' do
      config = double
      base_url = '1.0.0.0:4000/index'
      config.stub elasticsearch_url: base_url
      FactlinkUI::Application.stub config: config
      keywords = 'searching for this channel'
      results = double
      error_response = 'error has happened server side'
      results.stub response: error_response
      results.stub code: 501
      HTTParty.should_receive(:get).
        and_return(results)
      logger = double
      error_message = "Server error, status code: 501, response: '#{error_response}'."
      logger.should_receive(:error).with(error_message)
      query = Queries::ElasticSearchAll.new keywords, 1, 20, logger: logger

      expect { query.call }.to raise_error(RuntimeError, error_message)
    end

    it 'url encodes correctly' do
      config = double
      base_url = '1.0.0.0:4000/index'
      config.stub elasticsearch_url: base_url
      FactlinkUI::Application.stub config: config
      keywords = '$+,:; @=?&=/'
      wildcard_keywords = '($%5C+,%5C:;*+OR+$%5C+,%5C:;)+AND+(@=%5C?&=/*+OR+@=%5C?&=/)'
      interactor = Queries::ElasticSearchAll.new keywords, 1, 20

      results = double
      results.stub code: 200
      results.stub parsed_response: { 'hits' => { 'hits' => [] } }

      HTTParty.should_receive(:get).
        with("http://#{base_url}/factdata,topic,user/_search?q=#{wildcard_keywords}&from=0&size=20&analyze_wildcard=true").
        and_return(results)

      interactor.call.should eq []
    end
  end
end
