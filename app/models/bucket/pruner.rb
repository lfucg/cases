class Bucket
  class Pruner

    def initialize(bucket, manifest)
      @bucket = bucket
      @manifest = manifest
    end

    def prune
      @to_prune = []
      current = @bucket.events.select('id, row_checksum')
      current.each { |ev| maybe_prune(ev) }
      PruneWorker.perform_async(@to_prune)
      @pruned = true
    end

    def updated_manifest
      return unless @pruned
      @manifest
    end

    private

    def maybe_prune(event)
      idx = @manifest.index(event.row_checksum)
      idx.present? ? @manifest.delete_at(idx) : @to_prune << event.id
    end

  end
end
