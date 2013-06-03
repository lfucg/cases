require 'mapquest_batch'
class GeocodeBatchWorker
  include Sidekiq::Worker

  def perform(bucket_id, batch)
    bucket = Bucket.find(bucket_id)
    batch.reject! { |location| geocode_from_cache(bucket, location) }
    geocode(bucket, batch)
  end

  private

  def geocode_from_cache(bucket, location)
    return unless cached?(location)
    update_event(bucket, location, GeocodeCache[location])
  end

  def geocode(bucket, batch)
    results = MapquestBatch.geocode(batch)
    update_events(bucket, results)
  end

  def update_events(bucket, results)
    locations = results['results'].collect{ |res| location_data(res) }
    locations.compact.each { |loc| cache_and_update_event(bucket, loc[:location], loc[:coords]) }
  end

  def cache_and_update_event(bucket, location, coords)
    cache(location, coords)
    update_event(bucket, location, coords)
  end

  def location_data(result)
    location = result['providedLocation']['location']
    coords_data = result['locations'].first
    return unless coords_data
    coords = coords_data['latLng']
    { location: location, coords: [coords['lat'], coords['lng']] }
  end

  def update_event(bucket, location, coords)
    events = bucket.events.where(location: location)
    events.each do |e|
      e.coords = "POINT(#{coords[1]} #{coords[0]})"
      e.geocoded = true
      e.save
    end
    true
  end

  def cached?(location)
    GeocodeCache[location]
  end

  def cache(location, coords)
    GeocodeCache[location] = coords
  end
end
