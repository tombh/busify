(function() {

  Busify.Models.Plan = Backbone.Model.extend({

    paramRoot: 'plan',

    defaults: {
      match: null,
      meta: null
    }

  });

  Busify.Collections.PlansCollection = Backbone.Collection.extend({
    model: Busify.Models.Plan,
    url: '/plan'
  });

}).call(this);
