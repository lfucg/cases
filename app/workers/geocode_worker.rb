class GeocodeWorker
  include Sidekiq::Worker

  def perform(bucket_id)
    bucket = Bucket.find(bucket_id)
    bucket.events.geocodeable.select('id, address, hashed_address').find_in_batches(batch_size: 100) do |batch|
      converted_batch = batch.collect{ |e| [e.id, e.address, e.hashed_address] }
      run_batch(converted_batch)
    end
  end

  private
  
  def run_batch(batch)
    GeocodeBatchWorker.perform_async(batch)
  end
end
