require 'pavlov_helper'
require_relative '../../../app/interactors/queries/elastic_search.rb'
require_relative '../../../app/interactors/queries/elastic_search_user.rb'

describe Queries::ElasticSearchUser do
  include PavlovSupport

  before do
    stub_classes 'HTTParty', 'User', 'FactlinkUI::Application', 'KillObject'
  end

  describe '#call' do
    it 'executes correctly with return value of User class' do
      config = double
      base_url = '1.0.0.0:4000/index'
      config.stub elasticsearch_url: base_url
      FactlinkUI::Application.stub config: config
      keywords = 'searching for users'
      wildcard_keywords = '(searching*+OR+searching)+AND+(for*+OR+for)+AND+(users*+OR+users)'
      query = described_class.new keywords: keywords, page: 1, row_count: 20
      hit = {
        '_id' => 1,
        '_type' => 'user'
      }
      mongoid_user = double
      results = double code: 200, parsed_response: { 'hits' => { 'hits' => [ hit ] } }

      user = double

      HTTParty.should_receive(:get).
        with("http://#{base_url}/user/_search?q=#{wildcard_keywords}&from=0&size=20&analyze_wildcard=true").
        and_return(results)
      User.should_receive(:find).with(1).and_return(mongoid_user)
      KillObject.should_receive(:user).with(mongoid_user).and_return(user)

      expect(query.call).to eq [user]
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
      error_message = "Server error, status code: 501, response: '#{error_response}'."

      query = described_class.new keywords: keywords, page: 1, row_count: 20

      HTTParty.should_receive(:get).and_return(results)

      expect { query.call }.to raise_error(RuntimeError, error_message)
    end

    it 'url encodes keywords' do
      config = double
      base_url = '1.0.0.0:4000/index'
      config.stub elasticsearch_url: base_url
      FactlinkUI::Application.stub config: config
      keywords = '$+,:; @=?&=/'
      wildcard_keywords = '($%5C+,%5C:;*+OR+$%5C+,%5C:;)+AND+(@=%5C?&=/*+OR+@=%5C?&=/)'
      query = described_class.new keywords: keywords, page: 1, row_count: 20
      hit = {
        '_id' => 1,
        '_type' => 'user'
      }
      results = double code: 200, parsed_response: { 'hits' => { 'hits' => [ hit ] } }
      mongoid_user = double
      user = double

      HTTParty.should_receive(:get).
        with("http://#{base_url}/user/_search?q=#{wildcard_keywords}&from=0&size=20&analyze_wildcard=true").
        and_return(results)
      User.should_receive(:find).with(1).and_return(mongoid_user)
      KillObject.should_receive(:user).with(mongoid_user).and_return(user)

      expect(query.call).to eq [user]
    end
  end
end
