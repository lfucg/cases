# New import, seed the bucket
class SeedWorker
  include Sidekiq::Worker

  def perform(bucket_id, file)
    import = MassImport.new(bucket_id, file)
    import.run
    geocode(bucket_id)
  end

  private

  def geocode(bucket_id)
    GeocodeWorker.perform_async(bucket_id)
  end

end
