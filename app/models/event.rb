class Event < ActiveRecord::Base
  belongs_to :bucket
  belongs_to :place

  set_rgeo_factory_for_column(:coords,
      RGeo::Geographic.spherical_factory(srid: 4326))

  validates :datetime, presence: true
  validates :description, presence: true
  validates :location, presence: true

  scope :geocodeable, where(geocode_status: 'new')

  def lat
    coords.try(:lat)
  end

  def lon
    coords.try(:lon)
  end

  def date
    datetime.to_date
  end

  def sync_with_place(place)
    self.geocode_status = place.geocode_status
    self.place = place
    if place.geocode_complete?
      coords = place.coords
      lat, lon = coords.lat, coords.lon
      self.coords = "POINT(#{lon} #{lat})"
    end
    self.save
  end
end
