showFrame = document.getElementById("frame")
last_created_text = null

window.remote = Factlink.createFrameProxyObject window.parent,
  ['hide', 'show', 'highlightNewFactlink', 'stopHighlightingFactlink',
    'createdNewFactlink', 'trigger', 'setFeatureToggles'
  ]

local =
    showFactlink: (id, successFn) ->
      url = "/client/facts/#{id}"
      showUrl url, successFn

    prepareNewFactlink: (text, siteUrl, siteTitle, guided, successFn) ->
      url = "/facts/new" +
              "?fact=" + encodeURIComponent(text) +
              "&url=" + encodeURIComponent(siteUrl) +
              "&title=" + encodeURIComponent(siteTitle) +
              "&guided=" + encodeURIComponent(guided)
      showUrl url, successFn
      last_created_text = text

Factlink.listenToWindowMessages null, local

window.highlightLastCreatedFactlink = (id, text) ->
  if last_created_text == text
    remote.highlightNewFactlink(text, id)

showUrl = (url, successFn) ->
  window.onModalReady = ->
    window.onModalReady = -> # nothing
    successFn()

  backbone = showFrame.contentWindow.Backbone
  history = backbone?.history
  if history && backbone.History.started
    # Force (re)loading the url, even if already showing that url
    # If history.fragment is equal to the current url, it doesn't reload,
    # so we reset it to null
    history.fragment = null

    history.navigate url, trigger: true
  else
    showFrame.onload = -> window.onModalReady()
    showFrame.src = url

showFrame.src = '/client/blank'
