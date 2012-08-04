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
    url: '/stops',

    markers: [],

    /**
     * When the map's boundaries change update the collection
     */
    boundsChange: function(bounds){
      this.fetch({
        add: true,
        data : {
          bl_long: bounds.getSouthWest().lng(),
          bl_lat: bounds.getSouthWest().lat(),
          tr_long: bounds.getNorthEast().lng(),
          tr_lat: bounds.getNorthEast().lat()
        }
      });
    }
  });

}).call(this);
