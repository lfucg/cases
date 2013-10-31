require 'csv'
# Handles checking for rows that already exist in the db, so
# the entire db doesn't have to be purged on each import.
#
# This worker runs through each CSV row, building a list of
# checksums to compare against what is already in the database.
#
# Rows that are in the db that aren't on the manifest of keys
# are deleted via Bucket::Pruner#prune.
#
# Once the rows are pruned, new rows on the CSV are imported.
#
# After the import the GeocodeWorker is run to geocode the
# new rows.
#
class ManifestWorker
  include Sidekiq::Worker

  def perform(bucket_id, file)
    @bucket = Bucket.find(bucket_id)
    @file = file
    prune
    import
    geocode
  end

  private

  def prune
    @pruner = Bucket::Pruner.new(@bucket, manifest)
    @pruner.prune
  end

  def manifest
    keys = []
    CSV.foreach(@file) { |r| keys << r[0] }
    keys
  end

  def import
    return if @pruner.updated_manifest.empty?
    CSV.foreach(@file) { |r| maybe_import_row(r) }
  end

  def maybe_import_row(row)
    return unless @pruner.updated_manifest.include?(row[0])
    import_row(row)
  end

  def import_row(row)
    e = @bucket.events.new
    e.row_checksum = row[1]
    e.description = row[2]
    e.datetime = convert_datetime(row[3])
    e.location = row[4]
    e.save
  end

  def convert_datetime(str)
    DateTime.strptime(str, '%Y-%m-%d %H:%M:%S %z')
  end

  def geocode
    GeocodeWorker.perform_async(@bucket.id)
  end

end
