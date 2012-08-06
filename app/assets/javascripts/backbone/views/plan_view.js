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

      var from = this.options.plan.from;
      var to = this.options.plan.to;
      if(from && to){
        this.options.plans.fetch({
          add: true,
          data: {
            from: from,
            to: to
          }
        });
      }
    },

    addAll: function() {
      this.options.plans.each(this.addOne, this);
    },

    addOne: function(plan) {
      
      // Prevent excess hits to the DirectionsService API
      if(this.added) return;
      console.log('plan added', plan);
      
      // Just work on the first match for now
      var match = plan.get('match')[2];

      function waypoint(latLng){
        return {
          location: latLng
          // don't use 'stopover: false' it jerks some of the waypoint paths
        };
      }

      var batch = {};
      batch.waypoints = [];
      var batches = [];
      var latLng;
      $.each(match.stops, function(index, stop){
        latLng = new google.maps.LatLng(stop.lat, stop.lng);
        if(batch.waypoints.length === 0){
          if(typeof batch.origin == 'undefined'){
            // Only ever fired on the first batch
            batch.origin = latLng;
          }else{
            // Second step of any batch
            batch.waypoints = [waypoint(latLng)];
            batch.travelMode = google.maps.TravelMode.BICYCLING;
          }
        }else if(batch.waypoints.length == 8){
          batch.destination = latLng;
          batches.push(batch);
          // And start all over again
          batch = {};
          // The start of succesive batch needs to be the same stop as the end of a previous stop
          batch.origin = latLng;
          batch.waypoints = [];
        }else{
          batch.waypoints.push(waypoint(latLng));
        }
      });

      // Now append the remainder, if there is any
      if(batch.waypoints.length > 0){
        // Allow the last waypoint become the destination instead
        batch.waypoints.pop();
        batch.destination = latLng;
        batches.push(batch);
      }

      console.log('batches', batches);

      var self = this;
      var paths = [];
      var batches_complete = 0;
      $.each(batches, function(batch_index, batch){
        self.directionsService.route(batch, function(response, status) {
          if (status == google.maps.DirectionsStatus.OK) {
            $.each(response.routes[0].legs, function(leg_index, leg){
              $.each(leg.steps, function(step_index, step){
                paths = paths.concat(step.lat_lngs);
              });
            });

            batches_complete += 1;

            if(batches_complete == batches.length){
              console.log("rendering " + paths.length);
              var route = new google.maps.Polyline({
                path: paths,
                strokeColor: "#FF0000",
                strokeOpacity: 0.5,
                strokeWeight: 4
              });

              route.setMap(self.options.map);
              //self.directionsDisplay.setDirections(response);
              self.added = true;

            }
          }
        });
      });

      

    },

    render: function() {
      return this;
    }

  });

}).call(this);
