class BusStopsController < ApplicationController
  respond_to :json
  
  def show
    respond_with(BusStop.find(params[:id]))
  end

  # Return stops within a bounded rectangular region
  def within
    missing = []
    bounds = []

    [:bl_long, :bl_lat, :tr_long, :tr_lat].each do |arg|
      missing << arg if params[arg].blank?
      bounds << params[arg]
    end

    if missing.length > 0
      # response.status = 400
      respond_with({missing_params: missing})
      return
    end

    respond_with(BusStop.within(bounds))
  end


  







  def initialize
    @searched_routes = []
    @matches = []
  end

  def destination_in_route? route, depth = 0, route_stack = []
    depth += 1
    return if depth == 3
    return if @searched_routes.include? route
    
    route_stack += [{:route => route}]

    inouts = BusRoute.where(:number => route)

    stops = []
    inouts.each do |inout|
      stops += inout.stops
    end
    
    # Loop through immediate stops on the route
    stops.each do |stop|
      if stop == @destination
        @matches << Marshal.load(Marshal.dump(route_stack))
        break
      end
    end

    @searched_routes << route

    # Recursively search stops in child routes
    BusStop.where(:ATCOCode.in => stops).each do |stop|
      route_stack.last['stop'] = {
        :name => stop.CommonName,
        :ATCOCode => stop.ATCOCode
      }
      
      stop.bus_routes.each do |r|
        destination_in_route? r, depth, route_stack
      end

      if route == '1'
        # Recursively search stops in child routes
        nearbys = BusStop.near(:coordinates => stop.coordinates).limit(30)
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

  end

  def plan
    start_time = Time.now

    coords = params[:from].split(',')
    from = BusStop.near(:coordinates => [coords[0].to_f, coords[1].to_f]).first
    coords = params[:to].split(',')
    to = BusStop.near(:coordinates => [coords[0].to_f, coords[1].to_f]).first

    @destination = to.ATCOCode

    # Find all the routes serving the from-stop
    from.bus_routes.each do |route|
      # Look at all the stops on each route
      destination_in_route? route
    end

    meta = {
      from: [from.CommonName, from.ATCOCode],
      to: [to.CommonName, to.ATCOCode],
      time: Time.now - start_time,
      searched_routes: @searched_routes
    }

    respond_with(
      meta: meta,
      matches: @matches
    )
  end



end
