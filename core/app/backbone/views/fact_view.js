(function(){
window.FactView = Backbone.View.extend({
  tagName: "div",

  className: "fact-block",

  _currentTab: undefined,

  events: {
    "click a.remove": "removeFactFromChannel",
    "click li.destroy": "destroyFact",

    "click .tab-control .supporting"     : "tabClick",
    "click .tab-control .weakening"      : "tabClick",
    "click .tab-control .add_to_channel" : "tabClick",

    "click .title.edit": "toggleTitleEdit",
    "focus .title.edit>input": "focusTitleEdit",
    "blur .title.edit>input": "blurTitleEdit",
    "keydown .title.edit>input": "parseKeyInputTitleEdit",
    "click a.more": "showCompleteDisplaystring",
    "click a.less": "hideCompleteDisplaystring"
  },

  tmpl: Template.use("facts", "_fact"),

  initialize: function(opts) {
    this.model.bind('destroy', this.remove, this);
    this.model.bind('change', this.render, this);

    this.initAddToChannel();
    this.initFactRelationsViews();
    this.initUserPassportViews();

    this.wheel = new Wheel(this.model.get('fact_bubble')['fact_wheel']);
  },

  partials: {},

  render: function() {
    this.$el
      .html( this.tmpl.render(this.model.toJSON(), {
        fact_bubble: Template.use("facts","_fact_bubble"),
        fact_wheel: Template.use("facts","_fact_wheel"),
        interacting_users: Template.use("facts","_interacting_users")
      }));

    this.initAddToChannel();
    this.initFactRelationsViews();
    this.initUserPassportViews();

    this.$el.find('.authority').tooltip();

    if ( this.factWheelView ) {
      this.wheel.set(this.model.get('fact_wheel') || this.model.get('fact_bubble')['fact_wheel']);
      this.$el.find('.wheel').replaceWith(this.factWheelView.reRender().el);
    } else {
      this.factWheelView = new InteractiveWheelView({
        model: this.wheel,
        fact: this.model,
        el: this.$el.find('.wheel')
      }).render();
    }

    return this;
  },

  remove: function() {
    this.$el.fadeOut('fast', function() {
      $(this).remove();
    });

    // Hides the popup (if necessary)
    if ( parent.remote ) {
      parent.remote.hide();
      parent.remote.stopHighlightingFactlink(this.model.id);
    }
  },

  removeFactFromChannel: function(e) {
    e.preventDefault();

    if(!confirm("Are you sure you want to remove this Factlink from the current channel?")) return false;

    var self = this;

    this.model.removeFromChannel({
      error: function() {
        alert("Error while removing Factlink from Channel" );
      },
      success: function() {
        try {
          mpmetrics.track("Channel: Silence Factlink from Channel", {
            factlink_id: self.model.id,
            channel_id: currentChannel.id
          });
        } catch(e) {}
      }
    });
  },

  destroyFact: function(e) {
    e.preventDefault();

    if(!confirm("Are you sure you want to delete the Factlink you have created?")) return false;

    this.model.destroy({
      error: function() {
        alert("Error while removing the Factlink" );
      },
      success: function() {
        try {
          mpmetrics.track("Factlink: Destroy", {
            factlink_id: self.model.id
          });
        } catch(e) {}
      }
    });
  },

  initAddToChannel: function() {
    if ( this.$el.find('.tab-content .add_to_channel').length > 0 && typeof currentUser !== "undefined" ) {
      console.info(this.$el.find('.tab-content .add_to_channel')[0]);
      var addToChannelView = new AutoCompletedAddToChannelView({
        el: this.$el.find('.tab-content .add_to_channel')[0],
      })
      addToChannelView.render();
    }
  },

  initFactRelationsViews: function() {
    var supportingFactRelations = new SupportingFactRelations([], { fact: this.model } );
    var weakeningFactRelations = new WeakeningFactRelations([], { fact: this.model } );

    this.supportingFactRelationsView = new FactRelationsView({
      collection: supportingFactRelations,
      type: "supporting"
    });

    this.weakeningFactRelationsView = new FactRelationsView({
      collection: weakeningFactRelations,
      type: "weakening"
    });

   $('.supporting .dropdown-container', this.el)
   .append( this.supportingFactRelationsView.render().el );

   $('.weakening .dropdown-container', this.el)
   .append( this.weakeningFactRelationsView.render().el );
  },

  switchToRelationDropdown: function(type){
    try {
      mpmetrics.track("Factlink: Open tab", {
        factlink_id: self.model.id,
        type: type
      });
    } catch(e) {}

    if (type === "supporting") {
      this.weakeningFactRelationsView.hide();
      this.supportingFactRelationsView.showAndFetch();
    } else {
      this.supportingFactRelationsView.hide();
      this.weakeningFactRelationsView.showAndFetch();
    }
  },

  tabClick: function(e) {

    e.preventDefault();
    e.stopPropagation();

    var $target = $(e.target).closest('li');

    // Need a way to identify the clicked tab. Using the li class sucks monkeyballs.
    tab = $target.attr('class').split(' ')[0];

    // Remove .active
    var $tabButtons = this.$el.find('.tab-control li');
    $tabButtons.removeClass("active");

    if (tab !== this._currentTab) {
      // Open the clicked tab
      this._currentTab = tab;
      this.hideTabs();

      $target.addClass('active');
      // Show the tab
      this.$el.find('.tab-content > .' + tab).show();
      this.handleTabActions(tab);

    } else {
      // Same tab was clicked - hide it!
      this.hideTabs();
      this._currentTab = undefined;
    }
  },

  hideTabs: function() {
    $('.tab-content > div').hide();
  },

  handleTabActions: function(tab) {
    switch (tab) {
    case "supporting":
    case "weakening":
      this.switchToRelationDropdown(tab);
      return true;

    case "channels":
      return true;

    default:
      return true;
    }
  },

  initUserPassportViews: function() {
    var self = this;
    $(this.model.get("interacting_users")["activity"]).each(function()  {
      var el = $("li.user[data-activity-id="+ this.id + "]", self.el);
      var model = new User(this.user);
      var view = new UserPassportView({model: model, el: el, activity: this});
    });
  },

  highlight: function() {
    var self = this;
    self.$el.animate({"background-color": "#ffffe1"}, {duration: 2000, complete: function() {
      $(this).animate({"background-color": "#ffffff"}, 2000);
    }});
  },

  toggleTitleEdit: function () {
    var $editField = this.$el.find('.edit.title');

    if ( ! this._titleFieldHasFocus ) {
      $editField.toggleClass('edit-active');

      if ( $editField.hasClass('edit-active') ) {
        $editField.find('input').focus();
      }
    }
  },

  focusTitleEdit: function () {
    this._titleFieldHasFocus = true;
  },

  saveTitleEdit: function () {
    if ( this._titleFieldHasFocus ) {
      var self = this;
      var $titleField = this.$el.find('.edit.title');
      var value = $titleField.find('>input').val();

      $titleField.find('>span').html(value);
      $titleField.removeClass('edit-active');

      this._titleFieldHasFocus = false;

      if ( this.model.getTitle() === value ) {
        return;
      }

      // TODO: Please replace this with a proper Backbone.Model.prototype.save
      //       Once we got rid of Mustache
      if ( this.model.setTitle(value, { silent: true } ) ) {
        $.ajax({
          type: "PUT",
          url: this.model.url(),
          data: {
            title: value
          }
        }).done(function() {
          self.model.trigger('change');
        }).error(function() {
          alert("Something went wrong while trying to save this Factlink. Please try again");
        });
      }
    }
  },

  blurTitleEdit: function (e) {
    var $titleField = this.$el.find('.edit.title');
    var value = $titleField.find('>input').val();

    // Check if user has changes and wants to save
    if ( this.model.getTitle() !== value ) {
      if ( confirm("Do you want to save your changes?") ) {
        this.saveTitleEdit();
      } else {
        this.cancelTitleEdit();
      }
    }
  },

  cancelTitleEdit: function () {
    var $titleField = this.$el.find('.edit.title');
    var value = $titleField.find('>input').val();

    $titleField.find('>input').val( this.model.getTitle() );

    $titleField.removeClass('edit-active');
    this._titleFieldHasFocus = false;
  },

  parseKeyInputTitleEdit: function (e) {
    if ( e.keyCode === 13 ) {
      this.saveTitleEdit();

      e.preventDefault();
    } else if ( e.keyCode === 27 ) {
      this.cancelTitleEdit();

      e.preventDefault();
    }
  },

  showCompleteDisplaystring: function (e) {
    this.$el.find('.normal').hide()
      .siblings('.full').show();
  },

  hideCompleteDisplaystring: function (e) {
    this.$el.find('.full').hide()
      .siblings('.normal').show();
  }
});
})();
