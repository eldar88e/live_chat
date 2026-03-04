class RollbarJob < ApplicationJob
  queue_as :default

  def perform(payload)
    Rollbar.process_from_async_handler(payload)
  end
end
