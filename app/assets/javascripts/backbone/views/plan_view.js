(function() {

  (Busify.Views.Plans) || (Busify.Views.Plans = {});

  Busify.Views.Plans.PlanView = Backbone.View.extend({

    //template: JST["backbone/templates/plans/index"],
                        
    initialize: function(options) {

      this.options.plans.on('add', this.addOne, this);
      this.directionsService = new google.maps.DirectionsService();
      this.directionsDisplay = new google.maps.DirectionsRenderer();

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
      console.log('plan added', plan);
      if(this.options.plans.length == 1){
        this.renderPlan(plan);
      }
    },

    render: function() {
      return this;
    },



    /**
     * Render a journey plan onto the map
     */
    renderPlan: function(plan){
      // Just work on the first match for now
      var bus_journeys = plan.get('match');
      var batches;

      this.changes = [];

      var self = this;
      $.each(bus_journeys, function(index, journey){
        batches = self.createBatches(journey);
        self.renderJourney(batches);
      });

      this.renderChanges();
    },

    /**
     * Because the Directions API limits the number of waypoints to 8 we need to batch up
     * all the pieces from a Busify API match.
     * A 'journey' is a being on a bus without changing.
     * A 'route' is everything required to get from A to B, maybe including lots of 'journeys'
     */
    createBatches: function(journey){
      var batch = {};
      var batches = [];
      var latLng;
      batch.waypoints = [];
      var self = this;
      $.each(journey.stops, function(index, stop){
        latLng = new google.maps.LatLng(stop.lat, stop.lng);
        if(batch.waypoints.length === 0){
          if(typeof batch.origin == 'undefined'){
            // Only ever fired on the first batch
            batch.origin = latLng;
          }else{
            // Second step of any batch
            batch.waypoints = [{location: latLng}];
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
          batch.waypoints.push({location: latLng});
        }
      });

      // Now append the remainder, if there is any
      if(batch.waypoints.length > 0){
        // Allow the last waypoint become the destination instead
        batch.waypoints.pop();
        batch.destination = latLng;
        batches.push(batch);
      }

      self.changes.push(latLng);

      return batches;
    },

    renderJourney: function(batches){
      var self = this;
      var paths = [];
      var batches_complete = 0;
      $.each(batches, function(batch_index, batch){
        self.directionsService.route(batch, function(response, status) {
          if (status == google.maps.DirectionsStatus.OK) {
            // TODO Check for quota limit
            
            // The Directiosn API returns a deeply nested object.
            // A lot of drilling to get the honey.
            $.each(response.routes[0].legs, function(leg_index, leg){
              $.each(leg.steps, function(step_index, step){
                paths = paths.concat(step.lat_lngs);
              });
            });

            batches_complete += 1;

            if(batches_complete == batches.length){
              var route = new google.maps.Polyline({
                path: paths,
                strokeColor: '#'+Math.floor(Math.random()*16777215).toString(16),
                strokeOpacity: 0.5,
                strokeWeight: 4
              });

              route.setMap(self.options.map);
            }
          }
        });
      });
    },

    renderChanges: function(){
      var self = this;
      $.each(this.changes, function(index, change){
        new google.maps.Marker({
          position: change,
          map: self.options.map,
          title: index.toString()
        });
      });
    }
  
  });

}).call(this);
