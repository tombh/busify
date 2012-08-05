(function() {

  (Busify.Views.Map) || (Busify.Views.Map = {});

  Busify.Views.Map.IndexView = Backbone.View.extend({

    initialize: function(options) {

      var map = options.map;

      rad = function(x) {
        return x*Math.PI/180;
      };

      distHaversine = function(p1, p2) {
        var R = 6371; // earth's mean radius in km
        var dLat  = rad(p2.lat() - p1.lat());
        var dLong = rad(p2.lng() - p1.lng());

        var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(rad(p1.lat())) * Math.cos(rad(p2.lat())) * Math.sin(dLong/2) * Math.sin(dLong/2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        var d = R * c;

        return d.toFixed(3);
      };

      var self = this;
      google.maps.event.addListener(
        map,
        'bounds_changed',
        function() {
          var distance = distHaversine(map.oldCenter, map.getCenter());
          // console.log(distance);
          if(map.getZoom() > 13 && distance > 1) {
            map.oldCenter = map.getCenter();
            self.options.stops.boundsChange(map.getBounds());
          }
        }
      );

      var from_marker;
      var to_marker;

      function placeMarker(location) {
        if ( !from_marker ) {
          // Create our "tiny" marker icon
          from_marker = new google.maps.Marker({
            position: location,
            map: map,
            icon: "http://www.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png",
            draggable: true
          });
          return;
        }

        if ( !to_marker ) {
          to_marker = new google.maps.Marker({
            position: location,
            map: map,
            icon: "http://www.google.com/intl/en_us/mapfiles/ms/micons/green-dot.png",
            draggable: true
          });
        }

        $('.plan_handle').click(function(){
          var from = from_marker.getPosition().lat() + ',' + from_marker.getPosition().lng();
          var to = to_marker.getPosition().lat() + ',' + to_marker.getPosition().lng();
          window.router.navigate('plan', true);
          self.options.plans.fetch({
            add: true,
            data: {
              from: from,
              to: to
            }
          });
        });

        $('.plan_handle').show();

      }

      google.maps.event.addListener(map, 'click', function(event) {
        placeMarker(event.latLng);
      });

    }

  });

}).call(this);
