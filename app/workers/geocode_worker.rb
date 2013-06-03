class GeocodeWorker
  include Sidekiq::Worker

  def perform(bucket_id)
    bucket = Bucket.find(bucket_id)
    events = bucket.events.geocodeable.select('location')
    events.each_slice(100).to_a.each { |batch| run_batch(bucket, batch) }
  end

  private
  
  def run_batch(bucket, batch)
    GeocodeBatchWorker.perform_async(bucket.id, batch.collect(&:location))
  end
end
