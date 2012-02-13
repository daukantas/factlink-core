(function(){
window.GenericNotificationView = Backbone.View.extend({
  tagName: "li",
  className: "activity",

  initialize: function(options) {
    this.useTemplate("notifications", "_generic_activity");
  },

  render: function () {
    this.$el.html(Mustache.to_html(this.tmpl, this.model.toJSON()));
    return this;
  },

  clickHandler: function(e) {
    document.location.href = this.model.url();
  }
});

NotificationAddedEvidenceView = GenericNotificationView.extend({
  initialize: function(options) {
    this.useTemplate("notifications", "_added_evidence_activity");
  }
});

NotificationAddedSubchannelView = GenericNotificationView.extend({
  initialize: function(options) {
    this.useTemplate("notifications", "_added_subchannel_activity");
  }
});

window.NotificationView = function(opts) {

  switch (opts.model.get("action")) {
    case "added_supporting_evidence":
      return new NotificationAddedEvidenceView(opts);

    case "added_weakening_evidence":
      return new NotificationAddedEvidenceView(opts);

    case "added_subchannel":
      return new NotificationAddedSubchannelView(opts);

    default:
      return new GenericNotificationView(opts);
  }
};

}());