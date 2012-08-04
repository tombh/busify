(function($) {
    
    var dispatcher = new WebSocketRails('localhost:3002/websocket');
    
    dispatcher.on_open = function(data) {
      // console.log('Connection has been established: ' + data);
      // You can trigger new server events inside this callback if you wish.
    };

    /**
     * Haven't seen this fired yet.
     */
    dispatcher.on_close = function(data) {
      console.log('Connection has been closed: ' + data);
    };


    Backbone.sync = function (method, model, options) {
      var getUrl = function (object) {

        if (options && options.url) {
          return _.isFunction(options.url) ? options.url() : options.url;
        }
        
        if (!(object && object.url)) return null;
        return _.isFunction(object.url) ? object.url() : object.url;
      };

      var cmd = getUrl(model).split('/');
      var namespace = (cmd[0] !== '') ? cmd[0] : cmd[1]; // if leading slash, ignore

      var params = _.extend({
        req: namespace + ':' + method
      }, options);


      if ( !params.data && model ) {
        params.data = model.toJSON() || {};
      }

      /**
       * Watch for updates from long-running tasks
       */
      dispatcher.bind(namespace + '.update', function(data) {
        console.log(data);
        options.success(data);
      });

      var event_name = namespace + '.' + method;
      dispatcher.trigger(
        event_name,
        params.data,
        function(data){ options.success(data); },
        function(data){ options.error(data); }
      );

    };
})(jQuery);