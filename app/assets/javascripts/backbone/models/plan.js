(function() {

  Busify.Models.Plan = Backbone.Model.extend({

    paramRoot: 'plan',

    defaults: {

    }

  });

  Busify.Collections.PlansCollection = Backbone.Collection.extend({
    model: Busify.Models.Plan,
    url: '/plan'
  });

}).call(this);
