class ImportWorker
  include Sidekiq::Worker

  def perform
    each_import { |id, file| ImportFileWorker.perform_async(id, file) }
  end

  private

  def import_directory
    "/tmp/geoevents"
  end

  def each_import
    Dir["#{import_directory}/*.csv"].each do |file|
      bucket = find_or_create_bucket(file_slug(file))
      yield(bucket.id, file)
    end
  end

  def find_or_create_bucket(slug)
    bucket = Bucket.where(slug: slug).first
    return bucket if bucket
    bucket = Bucket.new
    bucket.name = slug.upcase
    bucket.save
    bucket
  end

  def file_slug(file)
    File.basename(file, ".csv").downcase
  end
end
