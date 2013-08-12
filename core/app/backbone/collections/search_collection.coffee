throttle = (method) ->
  _.throttle method, 300, leading: false

class window.SearchCollection extends Backbone.Collection
  constructor: (args...)->
    super(args...)
    @searchFor ''

  makeEmpty: ->
    @query = ''
    @reset []

  searchFor: throttle (query) ->
    query = $.trim(query)
    return if query == @query
    console.info "searching for #{query}"
    @jqxhr?.abort()

    if query == ''
      @makeEmpty()
    else
      @query = query
      @reset []
      @jqxhr = @fetch()

  encodedQuery: -> encodeURIComponent @query

  addNewItem: (compare_field) ->
    if @shouldShowNewItem(compare_field)
      @add @getNewItem()
      @trigger 'sync'

  shouldShowNewItem: (compare_field) ->
    @query != '' and not (@query.toLowerCase() in @newItemFields(compare_field))

  newItemFields: (compare_field) -> _.map @pluck(compare_field), (field)-> field.toLowerCase()

  getNewItem: -> console.error "'getNewItem' was not implemented"
