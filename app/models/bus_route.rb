class BusRoute
  include Mongoid::Document

  
  field :operator, :type => String
  field :number, :type => String
  field :direction, :type => String # Inbound/Outbound
  field :stops, :type => Array

  key :operator, :number, :direction

  has_many :bus_journeys

  def self.upsert(attributes)
    key = self.keygen(attributes)
    route = self.where(:_id => key).first
    if route.nil?
      self.create(attributes)
    else
      route.update_attributes!(attributes)
    end
  end

  def self.keygen attributes
    "#{attributes['operator']}-#{attributes['number']}-#{attributes['direction']}".downcase
  end

  def keygen
    BusRoute.keygen self.as_document
  end

end
