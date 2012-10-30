class GenericNotificationView extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "activity"
  template: "notifications/_generic_activity"
  events:
    'click a': 'click'

  click: (e) ->
    @trigger 'activityActivated'
    return Backbone.View.prototype.defaultClickHandler(e)

  onRender: ->
    @$el.addClass "unread" if @model.get("unread") is true

  markAsRead: -> @$el.removeClass "unread"

class NotificationAddedEvidenceView extends GenericNotificationView
  template: "notifications/_added_evidence_activity"

class NotificationAddedSubchannelView extends GenericNotificationView
  template: "notifications/_added_subchannel_activity"

class NotificationInvitedView extends GenericNotificationView
  template: "notifications/_invited_activity"

class NotificationCreatedConversationView extends GenericNotificationView
  template: "notifications/_created_conversation"

class NotificationRepliedMessageView extends GenericNotificationView
  template: "notifications/_replied_message"

window.NotificationView = (opts) ->
  switch opts.model.get("action")
    when "added_supporting_evidence", "added_weakening_evidence"
      new NotificationAddedEvidenceView(opts)
    when "added_subchannel"
      new NotificationAddedSubchannelView(opts)
    when "invites"
      new NotificationInvitedView(opts)
    when "created_conversation"
      new NotificationCreatedConversationView(opts)
    when "replied_message"
      new NotificationRepliedMessageView(opts)
    else
      new GenericNotificationView(opts)
