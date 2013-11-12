require 'mapquest_batch'
class GeocodeBatchWorker
  include Sidekiq::Worker

  def perform(batch)
    geocodeable = []

    ids = batch.collect{ |b| b[0] }
    @events = Event.where(id: ids)
    batch.each do |id, loc|
      event = @events.detect{ |x| x.id == id }
      place = Place.where(address: loc).first
      if place && place.geocode_complete?
        event.sync_with_place(place)
      elsif !place || (place && place.geocodeable?)
        geocodeable << [id, loc]
      end
    end

    geocode(geocodeable)
  end

  private

  def geocode(batch)
    locations = batch.collect{ |id, loc| loc }
    results = MapquestBatch.geocode(locations.uniq)
    update_events(batch, results)
  end

  def update_events(batch, results)
    locations = results['results'].collect{ |res| location_data(res) }
    locations.each do |loc|
      address = loc[:location]
      coords = loc[:coords]
      applicable_batch = batch.detect{|b| b[1] == address}
      id = applicable_batch[0] if applicable_batch
      e = @events.detect{|x| x.id == id} if id
      if e
        p = Place.where(address: address).first
        if !p
          p = Place.new
          p.address = address
          if coords
            lat, lng = coords
            p.coords = "POINT(#{lng} #{lat})"
            p.geocode_status = 'complete'
          else
            p.geocode_status = 'failed'
          end
          p.save
        end
        e.sync_with_place(p)
      end
    end
  end

  def location_data(result)
    data = {}
    data[:location] = result['providedLocation']['location']
    coords_data = result['locations'].first
    return data unless coords_data
    coords = coords_data['latLng']
    data[:coords] = [coords['lat'], coords['lng']]
    data
  end
end
