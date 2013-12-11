class GenericNotificationView extends Backbone.Marionette.Layout
  tagName: "li"
  className: "activity"
  templateHelpers: ->
    user: (new User @model.get('user')).toJSON()

  events:
    'click a': 'click'

  click: (e) ->
    @trigger 'activityActivated'
    return Backbone.View.prototype.defaultClickHandler(e)

  onRender: ->
    @$el.addClass "unread" if @model.get("unread") is true

  markAsRead: -> @$el.removeClass "unread"

class NotificationCreatedFactRelationView extends GenericNotificationView
  template: "notifications/created_fact_relation"

class NotificationCreatedConversationView extends GenericNotificationView
  template: "notifications/created_conversation"

class NotificationRepliedMessageView extends GenericNotificationView
  template: "notifications/replied_message"

class NotificationUserFollowedUser extends GenericNotificationView
  template: "notifications/user_followed_user"

  regions:
    addBackRegion: ".js-region-add-back"

  onRender: ->
    super()
    user = new User(@model.get('user'))
    @addBackRegion.show new FollowUserButtonView(user: user, mini: true)

class CreatedCommentOrSubCommentView extends GenericNotificationView
  template: "notifications/_created_comment_or_sub_comment"

window.NotificationView = (opts) ->
  switch opts.model.get("action")
    when "created_comment", "created_sub_comment"
      new CreatedCommentOrSubCommentView(opts)
    when "created_fact_relation"
      new NotificationCreatedFactRelationView(opts)
    when "created_conversation"
      new NotificationCreatedConversationView(opts)
    when "replied_message"
      new NotificationRepliedMessageView(opts)
    when "followed_user"
      new NotificationUserFollowedUser(opts)
    else
      throw 'Unknown notification action: ' + opts.model.get("action")
