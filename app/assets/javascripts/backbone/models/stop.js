(function() {

  Busify.Models.Stop = Backbone.Model.extend({

    paramRoot: 'stop',

    defaults: {
      ATCOcode: null,
      name: null,
      coordinates: null
    }

  });

  Busify.Collections.StopsCollection = Backbone.Collection.extend({
    model: Busify.Models.Stop,
    url: '/stops/within',

    markers: [],

    /**
     * When the maps boundaries change update the collection
     */
    boundsChange: function(bounds){
      this.fetch({
        add: true,
        data : {
          bl_long: bounds.ea.b,
          bl_lat: bounds.ca.b,
          tr_long: bounds.ea.j,
          tr_lat: bounds.ca.j
        }
      });
    }
  });

}).call(this);
