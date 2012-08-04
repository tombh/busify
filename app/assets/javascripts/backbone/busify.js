(function() {
  
  window.Busify = {
    Models:      {},
    Collections: {},
    Routers:     {},
    Views:       {}
  };

  $(document).ready(function(){
    var latlng = new google.maps.LatLng(51.452295, -2.585907); // Bristol
        
    // Google Maps Options
    var settings = {
        zoom: 12,
        center: latlng,
        mapTypeControl: false,
        navigationControlOptions: {
          style: google.maps.NavigationControlStyle.ANDROID
        },
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    
    // Add the Google Map to the page
    var map = new google.maps.Map(document.getElementById('map_canvas'), settings);
    map.oldCenter = new google.maps.LatLng(45, 0);
    window.router = new Busify.Routers.MapRouter({map: map});
    
    Backbone.history.start({pushState: true});
  });

}).call(this);

