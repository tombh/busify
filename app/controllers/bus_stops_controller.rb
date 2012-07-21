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

end
