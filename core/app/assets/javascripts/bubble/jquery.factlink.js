(function($) {
  var methods = {
    // Initialize factbubble
    init: function(options) {
      return this.each(function() {
        function stop_fade(t) {
          t.stop(true, true).css({
            "opacity": "1"
          });
        }

        function initialize($fact) {
         $fact.data("initialized", true);
        } /*start of method*/
        var $fact = $(this);
        $fact.data("facts", {});
        if (!$fact.data("initialized")) {
          initialize($fact);
        }
        $fact.find("article.fact").each(function() {
          var fact = init_fact(this, $fact);
          $fact.data("facts")[fact.attr("data-fact-id")] = fact;
        });
      });
    },

    update: function(data) {
      var $fact = $(this).data("container") || $(this);
      if ($fact.data("initialized")) {
        $(data).each(function() {
          var fact = $fact.data("facts")[this.id];
          if (fact && $(fact).data("initialized")) {
            $(fact).data("update")(this.score_dict_as_percentage); // Update the facts
          }
        });
      }
    },
    switch_opinion: function(opinion) {
      var fact = this,
          opinions = fact.data("wheel").opinions;
      opinions.each(function() {
        var current_op = this;
        if ($(current_op).data("opinion") === opinion.data("opinion")) {
          if (!$(current_op).data("user-opinion")) {
            $.post("/facts/" + $(fact).data("fact-id") + "/opinion/" + opinion.data("opinion") + ".json", function(data) {
              data_attr(current_op, "user-opinion", true);
              fact.factlink("update", data);
            });
          }
          else {
            $.ajax({
              type: "DELETE",
              url: "/facts/" + $(fact).data("fact-id") + "/opinion.json",
              success: function(data) {
                data_attr(current_op, "user-opinion", false);
                fact.factlink("update", data);
              }
            });
          }
        }
        else {
          data_attr(current_op, "user-opinion", false);
        }
      });
    },


    to_channel: function(user, channel, fact) {
      $.ajax({
        url: "/" + user + "/channels/toggle/fact",
        dataType: "script",
        type: "POST",
        data: {
          user: user,
          channel_id: channel,
          fact_id: fact
        }
      });
    }
  };

  $.fn.factlink = function(method) {
    // Method calling logic
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
    }
    else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments);
    }
    else {
      $.error('Method ' + method + ' does not exist on jQuery.factlink');
    }
  };

  // Private functions
  function data_attr(el, attr, data) {
    $(el).attr("data-" + attr, data);
    $(el).data(attr, data);
  }

  function init_fact(fact, container) {
    var $fact = $(fact);
    var $c = $(container);
    if (!$fact.data("initialized")) {
      $fact.find('.edit').editable('/facts/update_title', {
        indicator: 'Saving...',
        tooltip: 'Click to change the title of this Factlink',
        placeholder: "Click to add a title",
        width: "340"
      });

      $fact.data("container", container);
      $fact.data("wheel", new Wheel(fact));
      $fact.data("wheel").init($fact.find(".wheel").get(0));


      // Now setting a function in the jquery data to keep track of it, would be prettier with custom events
      $fact.data("update", function(data) {
        $fact.data("wheel").opinions.each(function() {
          data_attr(this, "value", data[$(this).data("opinions")].percentage);
        });
        data_attr($fact.data("wheel").authority,"authority",data.authority);
        $fact.data("wheel").update();
      });

      $fact.data("initialized", true);
    }
    return $fact;
  }
})(jQuery);
