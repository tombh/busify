class BusStop
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  field :ATCOCode, :type => String
  field :coordinates, :type => Array
  field :bus_routes, :type => Array

  index :ATCOCode, :unique => true
  index [[ :coordinates, Mongo::GEO2D ]], :min => -180, :max => 180

  # Return stops within a bounded rectangular region
  # bounds: [bl_long, bl_lat, tr_long, tr_lat]
  def self.within(bounds)
  	box = [ 
      [ bounds[0].to_f, bounds[1].to_f ],
      [ bounds[2].to_f,  bounds[3].to_f ]
    ]
    query = {:coordinates.within => {"$box" => box}}
    only = [:ATCOCode, :coordinates]
  	BusStop.where(query).only(only).limit(100)
  end

  def as_json(options={})
    attrs = super(options)
    attrs["id"] = attrs["_id"]
    attrs.delete "_id"
    attrs
  end

end
