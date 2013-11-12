# Geocode status could be:
#   - new
#   - complete
#   - failed
class Place < ActiveRecord::Base
  has_many :events

  set_rgeo_factory_for_column(:coords,
      RGeo::Geographic.spherical_factory(srid: 4326))

  validates :address, presence: true

  def set_coords(lat, lon)
    self.coords = "POINT(#{lon}, #{lat})"
  end

  def geocodeable?
    geocode_status == 'new'
  end

  def geocode_complete?
    geocode_status == 'complete'
  end
end
