require 'zip'

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
      csv << ['Date', 'Address', 'Description', 'Latitude', 'Longitude']
      bucket.events.find_each(batch_size: 5000) do |e|
        csv << [e.date.strftime('%Y-%m-%d'), e.address, e.description, e.lat, e.lon]
      end
    end
    zip(bucket, file)
  end

  def zip(bucket, file)
    zip = "#{DUMP_DIR}/#{bucket.name}.zip"

    # Delete the zip file if it exists
    File.delete(zip) if File.exists?(zip)

    Zip::File.open(zip, Zip::File::CREATE) do |zipfile|
      zipfile.add("#{bucket.name}.csv", file)
    end
    bucket.bulk_csv_created_at = Time.now
    bucket.bulk_csv_filesize = File.size(zip)
    bucket.save
  end

end
