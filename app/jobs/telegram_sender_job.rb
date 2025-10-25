class TelegramSenderJob < ApplicationJob
  queue_as :default

  def perform(**args)
    TelegramService.call(
      id: args[:id] || args['tg'],
      msg: args[:msg] || args['msg'],
      token: args[:token] || args['token']
    )
  end
end
