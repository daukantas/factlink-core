window.User = Backbone.Model.extend({
  channels: [],
  setChannels: function(channels) {
    this.channels = channels;
  },

  url: function(forProfile) {
    if (forProfile == true) {
      return '/' + this.get('username') + ".json";
    } else {
      return '/' + this.get('username');
    }
  },

  sync: function(method, model, options) {
    options = options || {};
    var forProfile = options.forProfile;

    options.url = model.url(forProfile);

    Backbone.sync(method, model, options);
  },

  is_current_user: function(){
    return (window.currentUser !== undefined && currentUser.get('id') === this.get('id'));
  },

  toJSON: function(){
    var json = Backbone.Model.prototype.toJSON.apply(this);
    return _.extend(json,{
      'is_current_user': this.is_current_user(),
      'edit_path': '/' + this.get('username') + '/edit',
      'change_password_path': '/' + this.get('username') + '/password/edit'
    })
  }
});
