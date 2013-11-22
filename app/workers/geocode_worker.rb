# GeocodeWorker syncs events with cached data or spawns workers to geocode data when
# the cached data is not present.
class GeocodeWorker
  include Sidekiq::Worker

  # MapQuest Batch has a 100 address geocoding limit
  BATCH_SIZE = 100

  def perform(bucket_id)
    bucket = Bucket.find(bucket_id)
    @remote_geocodeable = {}
    @remote_geocodeable_count = 0

    bucket.events.geocodeable.find_in_batches(batch_size: 10) do |batch|
      batch.each { |e| geocode(e) }
    end
    run_batch unless @remote_geocodeable.empty?
  end

  private

  def geocode(event)
    maybe_run_batch
    place = Place.where(hashed_address: event.hashed_address).first
    place.present? ? event.sync_with_place(place) : maybe_add_to_batch(event)
  end

  def maybe_run_batch
    if @remote_geocodeable_count == BATCH_SIZE
      run_batch
      @remote_geocodeable = {}
      @remote_geocodeable_count = 0
    end
  end

  def maybe_add_to_batch(event)
    add_to_batch(event) unless @remote_geocodeable.key?(event.hashed_address)
  end

  def add_to_batch(event)
    @remote_geocodeable[event.hashed_address] = event.address
    @remote_geocodeable_count += 1
  end
  
  def run_batch
    GeocodeRemoteWorker.perform_async(@remote_geocodeable)
  end

end
