class window.GlobalFeedActivities extends Backbone.Factlink.Collection
  _.extend @prototype, AutoloadCollectionOnTimestamp
  model: Activity

  url: -> '/api/beta/feed'

  initialize: (models, options={}) ->
    @_count = options.count || 20

  url: -> "/api/beta/feed.json?count=#{@_count}"


class window.PersonalFeedActivities extends Backbone.Collection
  _.extend @prototype, AutoloadCollectionOnTimestamp
  model: Activity

  url: -> '/api/beta/feed/personal'
