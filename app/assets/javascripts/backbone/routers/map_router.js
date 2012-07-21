(function() {

  Busify.Routers.MapRouter = Backbone.Router.extend({

    initialize: function(options) {
      options.stops = new Busify.Collections.StopsCollection();
      this.options = options;
    },

    routes: {
      ".*"       : "index"
    },

    index: function() {
      new Busify.Views.Map.IndexView(this.options);
      new Busify.Views.Stops.StopView(this.options);
    }

  });

}).call(this);
