require 'csv'
# Handles checking for rows that already exist in the db, so
# the entire db doesn't have to be purged on each import.
#
# This worker runs through each CSV row, building a list of
# checksums to compare against what is already in the database.
class ManifestWorker
  include Sidekiq::Worker

  BATCH_SIZE = 90

  def perform(bucket_id, file)
    bucket = Bucket.find(bucket_id)

    import_series = bucket.import_series + 1
    bucket.import_series = import_series
    bucket.save

    row_batch = []

    # Process a batch of CSV rows
    process_batch = ->() do

      checksums = row_batch.collect { |r| r[1] }
      events = bucket.events.where('row_checksum IN (?)', checksums).select('id, row_checksum')

      to_update = []

      # Iterate through each row in the batch
      #
      # If there is a matching fetched event, delete
      # it from the batch so we can create the leftover
      # events later.
      row_batch.each do |r|
        checksum = r[1]
        if e = events.detect{ |e| e.row_checksum == checksum }
          to_update << e.id
          row_batch.delete(r)
        end
      end

      unless row_batch.empty?
        sql = 'INSERT INTO events (bucket_id, import_series, row_checksum, address, datetime, description) VALUES '
        row_batch.each_with_index do |r, idx|
          values = [bucket_id, import_series, r[1], r[4], r[3], r[2]]
          quoted = values.collect{ |v| quote(v) }
          sql << "(#{quoted.join(', ')})"
          if idx != row_batch.size - 1
            sql << ", "
          else
            sql << ";"
          end
        end

        # Create rows
        result = ActiveRecord::Base.connection.execute(sql)
      end

      # Update the import series for valid events from a past import
      unless to_update.empty?
        set = "import_series = '#{import_series}'"
        conditions = "bucket_id = '#{bucket_id}' AND id IN (#{to_update.join(', ')})"
        Event.update_all(set, conditions)
      end
    end

    batch_count = 0

    CSV.foreach(file) do |r|
      if batch_count == BATCH_SIZE
        process_batch.call
        row_batch = []
        batch_count = 0
      end
      row_batch << r
      batch_count += 1
    end

    process_batch.call unless row_batch.empty?
      
    # Delete old events
    Event.delete_all(["bucket_id = ? AND import_series < ?", bucket_id, import_series])
    
    # Geocode addresses
    geocode(bucket_id)
  end

  private

  #def convert_datetime(str)
  #  DateTime.strptime(str, '%Y-%m-%d %H:%M:%S %z')
  #end

  def geocode(bucket_id)
    GeocodeWorker.perform_async(bucket_id)
  end

  def quote(str)
    ActiveRecord::Base.connection.quote(str)
  end

end
