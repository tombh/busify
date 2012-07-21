class BusJourney
  include Mongoid::Document

  # mondays: true,
  # tuesdays: true,
  # wednesdays: true,
  # thursdays: true,
  # fridays: true,
  # saturdays: true,
  # sundays: true,
  # vehicle_type: "COACH",
  # registration_number: "",
  # identifier: " 68269",
  # operator: "MB",
  # route_number: "M36",
  # route_direction: "O", # Inbound/Outbound
  # first_date_of_operation: "20110523",
  # last_date_of_operation: "20991231",
  # running_board: "",
  # school_term_time: "",
  # bank_holidays: "",

  field :key, :type => String
  field :arrivals, :type => Array
  field :departures, :type => Array

  index :key, :unique => true 
  belongs_to :bus_route

  def self.generate_key(attributes)
    "#{attributes['route_number']}-#{attributes['route_direction']}-#{attributes['departures'].first}"
  end 

  def self.upsert(attributes)
    journey = BusJourney.where(:key => generate_key(attributes))
    if journey.count == 0
      journey = BusJourney.create(:key => generate_key(attributes))
    else
      journey = journey.first
    end
    journey.update_attributes!(attributes)
  end

end
