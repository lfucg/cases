require 'csv'
class ImportWorker
  include Sidekiq::Worker

  CITY = 'Lexington'
  STATE = 'KY'

  def perform
    each_import do |bucket, file|
      bucket.events.destroy_all
      CSV.foreach(file) { |r| import_row(bucket, r) }
      GeocodeWorker.perform_async(bucket.id)
    end
  end

  private

  def import_directory
    @import_directory ||= "#{Rails.root}/import"
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

  def import_row(bucket, row)
    event = bucket.events.new
    event.description = row[0]
    event.date = Date.strptime(row[1], '%Y-%m-%d')
    event.location = append_city_state(row[2])
    event.save
  end

  def append_city_state(location)
    "#{location}, #{CITY}, #{STATE}"
  end

end
