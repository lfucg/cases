# Deletes events
class PruneWorker
  include Sidekiq::Worker

  def perform(ids)
    Event.delete(ids)
  end
end
