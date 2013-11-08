# Dump all data into files for bulk downloading
#
# This worker creates CSV and XML format file archives so consumers can
# get all available data in one go.
#
# This is typically ran daily.
#
# Once the files are generated, the bucket is updated with the generation
# time and filesize so users can see metadata next to each download link.
class DumpWorker
  include Sidekiq::Worker

  DUMP_DIR = File.join(Rails.root, 'public', 'bulk')

  def perform
    Bucket.all.each do |bucket|
      dump_csv(bucket)
    end
  end

  private

  def dump_csv(bucket)
    file = "#{DUMP_DIR}/#{bucket.name}.csv"
    CSV.open(file, 'w+') do |csv|
      csv << ['Date', 'Location', 'Description', 'Latitude', 'Longitude']
      bucket.events.find_each(batch_size: 5000) do |e|
        csv << [e.date.strftime('%Y-%m-%d'), e.location, e.description, e.lat, e.lon]
      end
    end
    bucket.bulk_csv_created_at = Time.now
    bucket.bulk_csv_filesize = File.size(file)
    bucket.save
  end

end
