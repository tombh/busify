class PlannerWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def initialize
    @searched_routes = []
    @matches = 0
  end

  def flesh_out_match match 
    stops = []
    match.each do |leg|
      leg[:stops].each do |stop|
        stops << stop
      end
    end

    stops = BusStop.where(:ATCOCode.in => stops.uniq).to_a
    stops = Hash[stops.map!{|s| [s.ATCOCode, s]}]

    fleshed_match = []
    match.each do |leg|
      fleshed_stops = []
      leg[:stops].each do |stop|
        if !stops.has_key? stop
          next
        end
        stop_full = stops[stop]
        flesh = {
          :name => stop_full.CommonName,
          :code => stop_full.ATCOCode,
          :lat => stop_full.coordinates[1],
          :lng => stop_full.coordinates[0],
        }
        fleshed_stops << flesh
      end
      leg_fleshed = {}
      leg_fleshed[:route] = leg[:route].split('-')[1]
      leg_fleshed[:stops] = fleshed_stops
      fleshed_match << leg_fleshed
    end
    fleshed_match
  end

  def match match

    puts "Match found!"

    @matches += 1
    
    match = flesh_out_match match

    meta = {
      :from => [@from.CommonName, @from.ATCOCode],
      :to => [@to.CommonName, @to.ATCOCode],
      :time => Time.now - @start_time,
      :searched_routes => @searched_routes
    }

    notify(
      :id => Time.now.to_i,
      :match => match,
      :meta => meta
    )
  end

  def destination_in_route? route, route_stack = [], depth = 0
    depth += 1
    return if depth == 3
    return if @searched_routes.include? route

    route_stack = Marshal.load(Marshal.dump(route_stack))
    current_leg = route_stack.pop

    puts "Searching #{route} at depth #{depth}"    

    stops = BusRoute.where(:_id => route).first.stops
    # Slice off the stops from the stops in the last leg of the journey
    # to the end of the route.
    index = stops.index(current_leg[:stops].last)
    stops = stops[(index + 1)..-1]

    # Loop through immediate stops on the route
    stops.each do |stop|
      # Keep track of how we got to this route/depth/stop through all the recursion
      current_leg[:stops].push(stop)
      if stop == @destination
        match route_stack + [current_leg]
        break
      end
    end

    @searched_routes << Marshal.load(Marshal.dump(route))

    stops_full = BusStop.where(:ATCOCode.in => stops.uniq).to_a
    stops_full = Hash[stops_full.map!{|s| [s.ATCOCode, s]}]
    
    current_leg[:stops] = [current_leg[:stops].shift]

    # Recursively search stops in child routes
    stops.each do |stop|
      stop = stops_full[stop]
      
      if stop.nil?
        # why does this happen!?
        # p stop
        next
      end
      
      current_leg[:stops].push(stop.ATCOCode)
      nearbys = BusStop.near(:coordinates => stop.coordinates).limit(5)
      return if nearbys.nil?
      nearbys.each do |nearby|
        next if nearby.bus_routes.nil?
        nearby.bus_routes.each do |r|
          next_leg = {
            :route => r,
            :stops => [nearby.ATCOCode]
          }
          if route_stack.length == 0
            route_stack_pass = [current_leg] + [next_leg]
          else
            route_stack_pass = route_stack + [current_leg] + [next_leg]
          end
          destination_in_route? r, route_stack_pass, depth
        end
      end
    end
  end

  def perform params

    @start_time = Time.now

    # TODO Use n nearest stops to from/to coords?


    coords = params['from'].split(',')
    froms = BusStop.near(:coordinates => [coords[1].to_f, coords[0].to_f]).limit(3)
    coords = params['to'].split(',')
    tos = BusStop.near(:coordinates => [coords[1].to_f, coords[0].to_f]).limit(3)

    tos.each do |to|
      froms.each do |from|
        return if @matches > 0

        @searched_routes = []
        
        @from = from
        @to = to

        @destination = @to.ATCOCode

        if @from.bus_routes.nil?
          p "From stop, '#{@from.ATCOCode}' doesn't have any bus routes!"
          next
        end

        # Find all the routes serving the from-stop
        @from.bus_routes.each do |route|

          route_stack = [{
            :route => route,
            :stops => [@from.ATCOCode]
          }]
          # Look at all the stops on each route
          destination_in_route? route, route_stack
        end
      end
    end    
  end  

end