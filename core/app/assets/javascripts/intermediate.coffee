showFrame = document.getElementById("frame")
xdm = window.easyXDM.noConflict("FACTLINK")
last_created_text = null
window.remote = new xdm.Rpc {},
  remote:
    hide: {}
    show: {}
    highlightNewFactlink: {}
    stopHighlightingFactlink: {}
    createdNewFactlink: {}
    trigger: {}

  local:
    showFactlink: (id, successFn) ->
      url = "/client/facts/#{id}"
      showUrl url, successFn
      return # don't return anything unless you have a callback on the other site of easyXdm

    prepareNewFactlink: (text, siteUrl, siteTitle, guided, successFn, errorFn) ->
      url = "/facts/new" +
              "?fact=" + encodeURIComponent(text) +
              "&url=" + encodeURIComponent(siteUrl) +
              "&title=" + encodeURIComponent(siteTitle) +
              "&guided=" + encodeURIComponent(guided) +
              "&layout=client" # layout=client is still necessary to get the client sign in page
      showUrl url, successFn
      last_created_text = text
      return # don't return anything unless you have a callback on the other site of easyXdm

    position: (top, left) ->
      try
        showFrame.contentWindow.position top, left
      catch e # Window not yet loaded
        showFrame.onload = ->
          showFrame.contentWindow.position top, left
      return # don't return anything unless you have a callback on the other site of easyXdm

window.triggerHighlightNewFactlink = (id, text) ->
  if last_created_text == text
    remote.highlightNewFactlink(text, id)

showUrl = (url, successFn) ->
  successCalled = false
  onLoadSuccess = ->
    if !successCalled
      successCalled = true
      if $.isFunction(successFn)
        successFn()

  showFrame.onload = onLoadSuccess
  # Somehow only lower case letters seem to work for those events --mark
  $(document).on "modalready", onLoadSuccess
  loadUrl url
  showFrame.className = "overlay"

loadUrl = (url)->
  backbone = showFrame.contentWindow.Backbone
  history = backbone?.history
  if history? and backbone.History.started
    history.loadUrl url
  else
    showFrame.src = url

# initialize the page, so we are ready to render new pages fast
showUrl '/client/blank', -> window.remote.trigger 'intermediateFrameReady'
