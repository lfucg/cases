class ImportWorker
  include Sidekiq::Worker

  def perform
    each_import { |bucket, file| run_worker(bucket, file) }
  end

  private

  def import_directory
    "/tmp/geoevents"
  end

  def each_import
    Dir["#{import_directory}/*.csv"].each do |file|
      bucket = find_or_create_bucket(file_slug(file))
      yield(bucket, file)
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

  def run_worker(bucket, file)
    ManifestWorker.perform_async(bucket.id, file)
  end
end
