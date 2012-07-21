class BusRoute
  include Mongoid::Document

  field :number, :type => String
  field :direction, :type => String # Inbound/Outbound
  field :stops, :type => Array

  has_many :bus_journeys

  def self.upsert(attributes)
    route = self.where(attributes).first
    if route.nil?
      route = self.create(attributes)
    end
    route.update_attributes!(attributes)
  end

end
