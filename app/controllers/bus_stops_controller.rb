class BusStopsController < WebsocketRails::BaseController
  
  def show
    #respond_with(BusStop.find(params[:id]))
  end

  # Return stops within a bounded rectangular region
  def within
    missing = []
    bounds = []

    [:bl_long, :bl_lat, :tr_long, :tr_lat].each do |arg|
      missing << arg if message[arg].blank?
      bounds << message[arg]
    end

    # if missing.length > 0
    #   # response.status = 400
    #   respond_with({missing_params: missing})
    #   return
    # end
    stops = BusStop.within(bounds).as_json
    trigger_success stops
  end

end
