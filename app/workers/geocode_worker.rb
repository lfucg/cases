class GeocodeWorker
  include Sidekiq::Worker

  def perform(bucket_id)
    bucket = Bucket.find(bucket_id)
    locations = bucket.events.geocodeable.uniq.pluck(:location)
    locations.each_slice(100) { |batch| run_batch(bucket_id, batch) }
  end

  private
  
  def run_batch(bucket_id, batch)
    GeocodeBatchWorker.perform_async(bucket_id, batch)
  end
end
