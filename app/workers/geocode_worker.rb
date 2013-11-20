# GeocodeWorker syncs events with cached data or spawns workers to geocode data when
# the cached data is not present.
class GeocodeWorker
  include Sidekiq::Worker

  def perform(bucket_id)
    bucket = Bucket.find(bucket_id)
    bucket.events.geocodeable.find_in_batches do |b|
      run_batch(b.map(&:hashed_address).uniq)
    end
  end

  private

  def run_batch(hashed_addresses)
    GeocodeBatchWorker.perform_async(hashed_addresses)
  end

end
