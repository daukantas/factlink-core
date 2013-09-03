# HACK: We store the background page url by intercepting "navigate" (called
# when navigating from one page in our app to another page in our app using Backbone)
# and "loadUrl" (called when coming to a page from another site, directly, or
# when using the browser navigation features). We then check if the page is not the
# page of a discussion modal, using FactlinkApp.showFactRegex, and then save it as
# the current background url.
# When loading a new page (with loadUrl), we close the discussion modal, and check if
# the background page url is the same url as we're navigating to. In that case we simply
# stop calling the respective controller.

FactlinkApp.module "DiscussionModalOnFrontend", (DiscussionModalOnFrontend, MyApp, Backbone, Marionette, $, _) ->

  background_page_url = null

  shouldCloseDiscussionModal = (fragment) ->
    !FactlinkApp.showFactRegex.test(fragment) && FactlinkApp.discussionModalRegion.currentView?

  setBackgroundPageUrlHook = (fragment) ->
    unless FactlinkApp.showFactRegex.test(fragment) || background_page_url == fragment
      console.info "changing background_page_url from #{background_page_url} to #{fragment}"
      background_page_url = fragment
    true

  abortIfAlreadyOnBackgroundPageHook = (fragment) ->
    if shouldCloseDiscussionModal(fragment)
      DiscussionModalOnFrontend.closeDiscussion()

      already_on_the_background_page = (fragment == background_page_url)
      setBackgroundPageUrlHook fragment

      !already_on_the_background_page
    else
      setBackgroundPageUrlHook fragment

  DiscussionModalOnFrontend.initializer = ->
    background_page_url = Backbone.history.getFragment currentUser.streamLink()

    FactlinkApp.vent.on 'close_discussion_modal', ->
      Backbone.history.navigate background_page_url, true

    addBackboneHistoryLoadUrlHook abortIfAlreadyOnBackgroundPageHook
    addBackboneHistoryNavigateHook setBackgroundPageUrlHook

  DiscussionModalOnFrontend.openDiscussion = (fact) ->
    Backbone.history.navigate fact.get('url'), false

    newClientModal = new DiscussionModalContainer
    FactlinkApp.discussionModalRegion.show newClientModal
    newClientModal.mainRegion.show new NDPDiscussionView model: fact

  DiscussionModalOnFrontend.closeDiscussion = ->
    FactlinkApp.discussionModalRegion.close()
    FactlinkApp.ModalWindowContainer.close()

