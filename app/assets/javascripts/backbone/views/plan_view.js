(function() {

  (Busify.Views.Plans) || (Busify.Views.Plans = {});

  Busify.Views.Plans.PlanView = Backbone.View.extend({

    //template: JST["backbone/templates/plans/index"],
                        
    initialize: function(options) {

      this.options.plans.on('add', this.addOne, this);
      this.directionsService = new google.maps.DirectionsService();
      this.directionsDisplay = new google.maps.DirectionsRenderer();
      this.directionsDisplay.setMap(this.options.map);
      this.added = false;
    },

    addAll: function() {
      this.options.plans.each(this.addOne, this);
    },

    addOne: function(plan) {
      console.log(plan);
      if(this.added) return;
      var match = plan.get('match')[0];
      var first_stop = match.stops[0];
      var last_stop = match.stops.slice(-1)[0];
      var from = new google.maps.LatLng( first_stop.lat, first_stop.lng);
      var to = new google.maps.LatLng( last_stop.lat, last_stop.lng);
      console.log(from, to);
      var request = {
        origin: from,
        destination: to,
        travelMode: google.maps.TravelMode.DRIVING
      };
      var self = this;
      this.directionsService.route(request, function(response, status) {
        if (status == google.maps.DirectionsStatus.OK) {
          self.directionsDisplay.setDirections(response);
          self.added = true;
        }
      });
    },

    render: function() {
      return this;
    }

  });

}).call(this);
