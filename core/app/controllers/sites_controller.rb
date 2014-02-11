class SitesController < ApplicationController
  # this action is called so many times, and is so fast
  # it totally distorts our newrelic stats, therefore
  # not counted in apdex
  newrelic_ignore_apdex only: [:facts_count_for_url] if defined?(NewRelic)

  def facts_count_for_url
    authorize! :get_fact_count, Site
    url = params[:url]
    if is_blacklisted
      response = { blacklisted: 'This site is not supported' }
    else
      site = Site.find(:url => url).first
      facts_count = site ? site.facts.count : 0
      response = { count: facts_count }
    end
    render_jsonp response
  end

  def facts_for_url
    url = params[:url]

    if is_blacklisted
      render_jsonp blacklisted: 'This site is not supported'
      return
    end

    unless can? :index, Fact
      render_jsonp error: 'Unauthorized'
      return
    end

    site = Site.find(url: url).first
    facts = site ? site.facts.to_a : []

    facts = facts.map do |fact|
      {
        id: fact.id,
        displaystring: fact.data.displaystring,
        title: fact.data.title
      }
    end

    render_jsonp facts
  end

  def blacklisted
    render_jsonp is_blacklisted ? { blacklisted: 'This site is not supported' } : {}
  end

  private

  def render_jsonp json_able
    if params[:callback]
      render json: json_able, callback: params[:callback], content_type: "application/javascript"
    else
      render json: json_able
    end
  end

  def is_blacklisted
    Blacklist.default.matches? params[:url]
  end
end
