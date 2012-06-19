window.ChannelList = Backbone.Collection.extend({
  model: Channel,
  reloadingEnabled: false,

  initialize: function() {
    this.bind('activate', this.setActiveChannel);
    this.bind('reset', this.checkActiveChannel);
  },

  url: function() {
    return '/' + this.getUsername() + '/channels';
  },

  setActiveChannel: function(channel) {
    if ( this.activeChannelId && this.activeChannelId !== channel.id ) {
      this.get(this.activeChannelId).trigger('deactivate');
    }

    this.activeChannelId = channel.id;
  },

  checkActiveChannel: function() {
    if ( this.activeChannelId ) {
      var activeChannel = this.get(this.activeChannelId);

      if ( activeChannel ) {
        activeChannel.trigger('activate', activeChannel);
      }
    }
  },

  getUsername: function() {
    if ( this._username ) {
      return this._username;
    }

    return false;
  },

  setUsername: function(name) {
    this._username = name;
  },

  shouldReload: function(){
    return ! ( typeof localStorage === "object"
      && localStorage !== null
      && localStorage['reload'] === "false" );
  },

  setupReloading: function() {
    if(this.shouldReload() && (! this.reloadingEnabled === true)) {
      this.reloadingEnabled = true;
      this.startReloading();
    }
  },

  startReloading: function(){
    if(this.shouldReload()) {
      var args = arguments;
      var self = this;
      setTimeout(function(){
        self.fetch({
          success: _.bind(args.callee, self),
          error:   _.bind(args.callee, self)
        });
      }, 7000);
    }
  }

});

window.Channels = new ChannelList();
