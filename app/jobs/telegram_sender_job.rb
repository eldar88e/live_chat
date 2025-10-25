class TelegramSenderJob < ApplicationJob
  queue_as :default

  def perform(**args)
    TelegramService.call(**args)
  end
end
