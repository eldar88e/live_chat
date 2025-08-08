class TelegramSenderJob < ApplicationJob
  queue_as :default

  def perform(msg)
    TelegramService.call(msg)
  end
end
