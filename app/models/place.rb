# Place is a cache of geocoded addresses
#
# Place makes it so we don't have to query a remote geocoding API
# to get address coordinates.
#
# If a place can't be geocoded the geocode_status is set so we don't
# keep retrying bad addresses.
#
# The address is hashed and index so we can easily query for events
# that share the same address hash and sync them.
#
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
    self.coords = "POINT(#{lon} #{lat})"
  end

  def geocodeable?
    geocode_status == 'new'
  end

  def geocode_complete?
    geocode_status == 'complete'
  end
end
