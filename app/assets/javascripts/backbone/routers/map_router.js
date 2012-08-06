(function() {

  Busify.Routers.MapRouter = Backbone.Router.extend({

    initialize: function(options) {
      options.stops = new Busify.Collections.StopsCollection();
      options.plans = new Busify.Collections.PlansCollection();
      this.options = options;
      new Busify.Views.Map.IndexView(this.options);
    },

    routes: {
      "" : "index",
      "plan/:from/:to" : "plan"
    },

    index: function() {
      new Busify.Views.Stops.StopView(this.options);
    },

    plan: function(from, to) {
      this.options.plan = {};
      this.options.plan.from = from;
      this.options.plan.to = to;
      new Busify.Views.Plans.PlanView(this.options);
    }

  });

}).call(this);
