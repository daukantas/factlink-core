FactlinkJailRoot.createFactFromSelection = ->
  text = window.document.getSelection().toString().trim()
  siteTitle = window.document.title
  siteUrl = FactlinkJailRoot.siteUrl()
  window.document.getSelection().removeAllRanges()
  FactlinkJailRoot.createButton.hide()

  FactlinkJailRoot.openModalOverlay()
  FactlinkJailRoot.factlinkCoreEnvoy 'prepareNewFactlink',
    text, siteUrl, siteTitle

FactlinkJailRoot.textSelected = ->
  # At least 4 words of at least 2 characters
  /(\w{2,}[\s-_&\/#%.,;:!()]+){4}/.test window.document.getSelection().toString()
