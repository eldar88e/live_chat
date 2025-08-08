class CableBroadcastJob < ApplicationJob
  queue_as :cable

  def perform(target, payload)
    ActionCable.server.broadcast(target, payload)
  end
end
