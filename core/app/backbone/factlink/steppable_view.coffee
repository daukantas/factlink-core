Backbone.Factlink ||= {}
class Backbone.Factlink.SteppableView extends Backbone.Marionette.CompositeView
  constructor: (args...)->
    super(args...)
    @on 'after:item:added', @onItemAddedDoSteppableInitialization, this
    @on 'composite:collection:rendered', => @setActiveView 0
    @on 'item:removed', @removeViewFromList

    @list = []

  closeList: -> @list = []

  close: (args...)->
    super(args...)
    @closeList()

  deActivateCurrent: () ->
    @currentActiveView()?.trigger('deactivate');
    @activeViewKey = `undefined`

  fixKeyModulo: (key)->
    if key >= @list.length then 0
    else if key < 0 then @list.length - 1
    else key

  setActiveView: (key)->
    @deActivateCurrent()
    key = @fixKeyModulo(key)
    view = @list[key]
    if view
      view.trigger('activate');
      @activeViewKey = key

  moveSelectionUp: ->
    prevKey = if @activeViewKey? then @activeViewKey - 1 else -1
    @setActiveView prevKey
    @scrollToCurrent()

  moveSelectionDown: ->
    nextKey = if @activeViewKey? then @activeViewKey + 1 else 0
    @setActiveView nextKey
    @scrollToCurrent()

  removeViewFromList: (view) ->
    i = @list.indexOf(view)
    @list.splice(i,1)

  onItemAddedDoSteppableInitialization: (view) ->
    @listenTo view, 'requestActivate', -> @requestActivate view

    @listenTo view, 'requestDeActivate', -> @deActivateCurrent()

    @listenTo view, 'requestClick', ->
      @requestActivate view
      @trigger 'click'

    @list.push(view)

  currentActiveModel: -> @currentActiveView()?.model

  currentActiveView: ->
    if 0 <= @activeViewKey < @list.length
      @list[@activeViewKey]
    else
     null

  scrollToCurrent: ->
    @currentActiveView()?.scrollIntoView?()

  requestActivate: (view) ->
    unless @alreadyHandlingAnActivate
      @alreadyHandlingAnActivate = true
      i = @list.indexOf(view)
      @setActiveView(i)
      @alreadyHandlingAnActivate = false
