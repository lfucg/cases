require 'mapquest_batch'

# GeocodeBatchWorker uses a remote geocoding service to geocode places
#
# The worker will make a remote call to a geocoding service (currently, Mapquest)
# and create a Place for each returned address.
#
# Once the place is created it gets synced with any corresponding events
# present in the batch.
class GeocodeBatchWorker
  include Sidekiq::Worker

  CITY = "Lexington"
  STATE = "KY"

  def perform(batch)
    addresses = batch.collect{ |hash, loc| full_address(loc) }
    geocoded_addresses = remote_geocode(addresses)
    geocoded_addresses.each do |address, coordinates|
      street = address.gsub(/, #{CITY}, #{STATE}/, '')
      hash = batch.detect{ |k,v| v == street }.first
      batch[hash] = coordinates
    end

    events = Event.where(hashed_address: batch.keys)
    places = Place.where(hashed_address: batch.keys)

    events.each do |event|
      lat, lng = batch[event.hashed_address]
      place = find_or_create_place(event, places, lat, lng)
      event.sync_with_place(place)
    end
  end

  private

  def full_address(street)
    "#{street}, #{CITY}, #{STATE}"
  end

  def remote_geocode(locations)
    results = MapquestBatch.geocode(locations)
    convert_results(results)
  end

  def convert_results(results)
    results['results'].collect{ |res| location_data(res) }
  end

  def location_data(result)
    data = []
    data << result['providedLocation']['location']
    coords_data = result['locations'].first
    return data unless coords_data
    coords = coords_data['latLng']
    data << [coords['lat'], coords['lng']]
    data
  end

  def find_or_create_place(event, places, lat, lng)
    place = places.detect{ |p| p.hashed_address == event.hashed_address }
    return place if place

    place = Place.new
    place.address = event.address
    if lat and lng
      place.set_coords(lat, lng)
      place.geocode_status = 'complete'
    else
      place.geocode_status = 'failed'
    end
    place.save
    place
  end

end
