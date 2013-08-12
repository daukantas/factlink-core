class window.NDPEvidenceCollection extends Backbone.Factlink.Collection

  initialize: (models, options) ->
    @fact = options.fact

    @_containedCollections = [
      new OpinionatersCollection null, fact: @fact
      new OneSidedEvidenceCollection null, fact: @fact, type: 'supporting'
      new OneSidedEvidenceCollection null, fact: @fact, type: 'weakening'
    ]

    for collection in @_containedCollections
      collection.on 'sync', @loadFromCollections, @

  comparator: (item) -> - item.get('impact')

  loading: ->
    _.some @_containedCollections, (collection) -> collection.loading()

  fetch: (options={}) ->
    @trigger 'request', this
    _.invoke @_containedCollections, 'fetch', options

  loadFromCollections: ->
    return if @loading()

    @reset(_.union (col.models for col in @_containedCollections)...)
