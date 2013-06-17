require 'csv'
class ImportWorker
  include Sidekiq::Worker

  def perform(bucket_slug, file)
    if bucket = Bucket.find_by_slug(bucket_slug)
      bucket.events.destroy_all
      CSV.foreach(file) { |r| import_row(bucket, r) }
      delete(file)
      GeocodeWorker.perform_async(bucket.id)
    end
  end

  private

  def import_row(bucket, row)
    event = bucket.events.new
    event.description = row[0]
    event.date = Date.strptime(row[1], '%Y-%m-%d')
    event.location = row[2]
    event.save
  end

  def delete(file)
    File.delete(file)
  end
end
