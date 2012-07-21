(function() {

  var markers = [];

  (Busify.Views.Stops) || (Busify.Views.Stops = {});

  Busify.Views.Stops.StopView = Backbone.View.extend({

    //template: JST["backbone/templates/stops/index"],
                        
    initialize: function(options) {

      this.options.stops.on('add', this.addOne, this);
        
    },

    addAll: function() {
      this.options.stops.each(this.addOne, this);
    },

    addOne: function(stop) {
      var position = new google.maps.LatLng( stop.get('coordinates')[1], stop.get('coordinates')[0]);
      
      var marker = new google.maps.Marker({
        position: position,
        map: this.options.map,
        title: stop.get('ATCOCode'),
        description: "description"
      });

      // Keep a record of markers, not used yet. There's no other way to access them.
      this.options.stops.markers.push(marker);
    },

    render: function() {
      //this.addAll();
      return this;
    }

  });

}).call(this);
