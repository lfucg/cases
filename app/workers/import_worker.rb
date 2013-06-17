require 'csv'
class ImportWorker
  include Sidekiq::Worker

  def perform
    each_import do |slug, file|
      if bucket = Bucket.find_by_slug(slug)
        bucket.events.destroy_all
        CSV.foreach(file) { |r| import_row(bucket, r) }
        delete(file)
        GeocodeWorker.perform_async(bucket.id)
      end
    end
  end

  private

  def import_directory
    @import_directory ||= "#{Rails.root}/import"
  end

  def each_import
    Dir["#{import_directory}/*.csv"].each do |file|
      yield(file_slug(file), file)
    end
  end

  def file_slug(file)
    File.basename(file, ".csv").downcase
  end

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
