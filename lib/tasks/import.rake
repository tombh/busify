require 'atco'
require 'csv'

namespace :import do

  desc "Import bus stop data"
  task :stops => :environment do
    puts "Loading Stops CSV ..."
    csv = CSV.read(Rails.root + 'db/NPTDR/Stops.csv', :encoding => 'ISO8859-1')
    fields = csv.shift

    puts "Persisting stops ..."
    csv.each do |row|

      # Combine the row with corresponding keys from the field strings in the first row of the CSV
      attributes = Hash[*fields.zip(row).flatten]
      
      next unless attributes['ParentLocality'] == 'Bristol' # TODO Remove in production

      # Geocoder requires coordinates to be in an array field
      attributes['coordinates'] = [attributes['Lon'].to_f, attributes['Lat'].to_f]
      attributes.delete('Lon')
      attributes.delete('Lat')
      
      stop = BusStop.where(:ATCOCode => attributes['ATCOCode'])
      if stop.count > 0
        stop.first.update_attributes!(attributes)
      else
        stop.create!(attributes)
      end
    end
    puts BusStop.all().count.to_s + " stops in the DB"
  end
  
  desc "Import CIF data"
  task :cif => :environment do
    # The ATCO parser has a custom to_json method that nicely formats the results.
    # So use that and convert back to a hash. 
    result = JSON.parse(Atco.parse(Rails.root + 'db/NPTDR/Admin_Area_010/ATCO_010_BUS.CIF').to_json)
    result['journeys'].each do |key, journey|
      journey['stop_codes'] = []
      journey['arrivals'] = []
      journey['departures'] = []
      stops = journey.delete('stops') # Delete is equivelant to popping a specific key
      stops.each do |stop|
        journey['stop_codes'] << stop['location'].strip
        journey['arrivals'] << stop['published_arrival_time']
        journey['departures'] << stop['published_departure_time']
      end
      route = {}
      route['operator'] = journey['operator']
      route['number'] = journey['route_number']
      route['direction'] = journey['route_direction']
      route['stops'] = journey['stop_codes']
      BusJourney.upsert(journey)
      BusRoute.upsert(route)
    end
  end


end

namespace :crunch do

  desc "Correlate routes to stops"
  task :routes => :environment do
    BusRoute.all().each do |route|
      route.stops.each do |atcocode|
        stop = BusStop.where(:ATCOCode => atcocode).first


        if stop.nil?
          # puts stop.to_yaml
          next
        end

        if stop.bus_routes
          included = stop.bus_routes.include? route.keygen
        else
          included = false
          stop.bus_routes = []
        end

        if !included
          stop.bus_routes << route.keygen
          stop.save!
        end
        
        # puts stop.bus_routes.to_yaml
      end
    end 
  end

end