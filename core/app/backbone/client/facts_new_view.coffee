class Tooltip
  constructor: ($) ->
    @$ = $
    @_shouldShowTooltip = true

  showTooltip: ->
    return if ( ! @_shouldShowTooltip )

    @$('.fact-wheel').tooltip(
      title: "What's your opinion?",
      trigger: "manual"
    ).tooltip('show');

  close: ->
    @_shouldShowTooltip = false
    $(window).off 'resize.whatsyouropinion'
    @$('.fact-wheel').off 'click.whatsyouropinion'
    @$('.js-opinion-animation').hide();
    @$('.fact-wheel').tooltip('destroy')

  render: ->
    @$('.fact-wheel').on 'click.whatsyouropinion', =>
      @close()

      if FactlinkApp.guided
        $('#submit').tooltip(
          title: "Great! Click here to finish",
          trigger: "manual"
        ).tooltip("show");

    $(window).on 'resize.whatsyouropinion', =>
      @showTooltip();

    @showTooltip()


class window.FactsNewView extends Backbone.Marionette.ItemView
  template: "client/facts_new"

  events:
    'click #submit': 'post_factlink'

  templateHelpers: ->
    layout: @options.layout
    fact_text: @options.fact_text
    title: @options.title
    url: @options.url
    add_to_channel_header: Factlink.Global.t.add_to_channels.capitalize()
    csrf_token: @options.csrf_token
    guided: FactlinkApp.guided

  initialize: ->
    @addToCollection = new OwnChannelCollection
    @tooltip = new Tooltip($)

  onRender: ->
    @renderAddToChannel()
    @renderSuggestedChannels()
    @renderPersistentWheelView()
    @createCancelEvent()
    sometimeWhen(
      => @$el.is ":visible"
    , => @tooltip.render()
    )

  onBeforeClose: ->
    @tooltip.close()

  renderAddToChannel: ->
    addToChannelView = new AutoCompleteChannelsView collection: @addToCollection
    addToChannelView.render()
    addToChannelView.on 'error', ->
      alert('Something went wrong when creating a new channel, sorry!')
    @$('#add-to-channels').html addToChannelView.el

  renderSuggestedChannels: ->
    if @options.url
      suggestionView = new FilteredSuggestedSiteTopicsView
        addToCollection: @addToCollection
        site_url: @options.url
      suggestionView.render()
      @$('#suggested-channels-region').html suggestionView.el

  renderPersistentWheelView: ->
    @wheel = new Wheel
    persistentWheelView = new PersistentWheelView
      el: @$('.fact-wheel'),
      model: @wheel
    persistentWheelView.render()

    persistentWheelView.on 'opinionSet', ->
      parent?.remote?.trigger('opinionSet')

  createCancelEvent: ->
    @$('#cancel').on 'click', (e)->
      mp_track("Modal: Cancel")
      e.preventDefault()
      # TODO when refactoring this view, move parent.remote code to clientcontroller
      parent.remote.hide()

  post_factlink: (e)->
    e.preventDefault()
    e.stopPropagation()

    channel_ids = @addToCollection.map (ch)-> ch.id

    f = new Fact
      opinion: @wheel.userOpinion()
      displaystring:  @$('textarea#fact').val()
      fact_url: @$('input#url').val()
      fact_title: @$('input#title').val()
      channels: channel_ids

    f.save {},
      success: ->
        f.set containing_channel_ids: channel_ids
        Backbone.history.loadUrl "facts/#{f.id}"
