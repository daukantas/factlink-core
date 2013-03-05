Backbone.Factlink ||= {}

Backbone.Factlink.TooltipMixin =
  
  tooltipAdd: (selector, view, options) ->
    @_tooltips ?= {}

    if @_tooltips[selector]?
      throw "Cannot call tooltipAdd multiple times with the same selector: #{selector}"

    @_tooltips[selector] = new Backbone.Factlink.PositionedRegion options
    @_tooltips[selector].show view
    
    @on 'render', @tooltipBindAll
    @on 'close', @tooltipResetAll

  tooltipBindAll: ->
    for selector, tooltipHandler of @_tooltips
      $bindEl = @$(selector).first()
      tooltipHandler.bindToElement($bindEl, @$el)
    
    @tooltipUpdateAll()

  tooltipUpdateAll: ->
    for selector, tooltipHandler of @_tooltips
      tooltipHandler.updatePosition()

  tooltipResetAll: ->
    for selector, tooltipHandler of @_tooltips
      tooltipHandler.reset()

  tooltip: (selector) ->
    @_tooltips?[selector]
