class PlannerWorker
  include Sidekiq::Worker

  def initialize
    @searched_routes = []
    @matches = []
  end

  def match match
    meta = {
      :from => [@from.CommonName, @from.ATCOCode],
      :to => [@to.CommonName, @to.ATCOCode],
      :time => Time.now - @start_time,
      :searched_routes => @searched_routes
    }

    notify(
      :match => match,
      :meta => meta
    )
  end

  def destination_in_route? route, depth = 0, route_stack = []
    depth += 1
    return if depth == 3
    return if @searched_routes.include? route

    puts "Searching #{route} at depth #{depth}"    

    # Get inbound and outbound version of route
    inouts = BusRoute.where(:number => route) 
    # TODO Proper unique keys for routes OPCODE:NAME:[I/O]
    # TODO Maybe not aggregate as we can't tell which I/O route a stop match belong to

    # Aggregate inbound/outbound stops
    stops = []
    inouts.each do |inout|
      stops += inout.stops
    end
    
    # Keep track of how we got to this route/depth/stop through all the recursion
    route_stack += [{:route => route}]
    
    # Loop through immediate stops on the route
    stops.each do |stop|
      if stop == @destination
        match route_stack
        break
      end
    end

    @searched_routes << Marshal.load(Marshal.dump(route))

    # Recursively search stops in child routes
    BusStop.where(:ATCOCode.in => stops).each do |stop|
      
      nearbys = BusStop.near(:coordinates => stop.coordinates).limit(5)
      return if nearbys.nil?
      nearbys.each do |nearby|
        route_stack.last['stop'] = {
          :name => stop.CommonName,
          :ATCOCode => stop.ATCOCode
        }
        next if nearby.bus_routes.nil?
        nearby.bus_routes.each do |r|
          destination_in_route? r, depth, route_stack
        end
      end
    end
  end

  def perform params
    @start_time = Time.now

    # TODO Use n nearest stops to from/to coords?

    coords = params['from'].split(',')
    @from = BusStop.near(:coordinates => [coords[0].to_f, coords[1].to_f]).first
    coords = params['to'].split(',')
    @to = BusStop.near(:coordinates => [coords[0].to_f, coords[1].to_f]).first

    @destination = @to.ATCOCode

    # Find all the routes serving the from-stop
    @from.bus_routes.each do |route|
      # Look at all the stops on each route
      destination_in_route? route
    end    
  end  

end