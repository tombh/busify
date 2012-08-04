(function() {

  (Busify.Views.Plans) || (Busify.Views.Plans = {});

  Busify.Views.Plans.PlanView = Backbone.View.extend({

    //template: JST["backbone/templates/plans/index"],
                        
    initialize: function(options) {

      this.options.plans.on('add', this.addOne, this);
        
    },

    addAll: function() {
      this.options.plans.each(this.addOne, this);
    },

    addOne: function(plan) {
      console.log(plan);
    },

    render: function() {
      return this;
    }

  });

}).call(this);
