require 'telegram/bot'

class TelegramService
  MESSAGE_LIMIT = 4_090

  def initialize(**args)
    @bot_token = args[:token] || settings[:tg_token]
    @chat_ids  = args[:id] || settings[:chat_ids]
    @message   = args[:msg]
  end

  def self.call(**args)
    new(**args).report
  end

  def report
    tg_send if bot_ready?
  end

  private

  def settings
    @settings ||= Setting.all_cached
  end

  def bot_ready?
    if @bot_token.present? && @chat_ids.present? && @message.present?
      @message = "‼️‼️Development‼️‼️\n\n#{@message}" if Rails.env.development?
      true
    else
      Rails.logger.error 'Telegram chat ID or bot token not set!'
      false
    end
  end

  def escape(text)
    text.gsub(/\[.*?m/, '').gsub(/([-_\[\]()~>#+=|{}.!])/, '\\\\\1') # delete `,*
  end

  def tg_send
    message_count = (@message.size / MESSAGE_LIMIT) + 1
    message_count.times do
      text_part = next_text_part
      send_telegram_message(text_part)
    end
    # TODO: Если нужно зафиксировать все msg_id нужно их поместить в array
    @message_id
  end

  def send_telegram_message(text_part)
    [@chat_ids.to_s.split(',')].flatten.each do |chat_id|
      Telegram::Bot::Client.run(@bot_token) do |bot|
        @message_id = bot.api.send_message(
          chat_id: chat_id, text: escape(text_part), parse_mode: 'MarkdownV2'
        ).message_id
      end
    rescue StandardError => e
      Rails.logger.error "Failed to send message to bot: #{e.message} | #{@message} | #{chat_ids}"
      @message_id = e
    end
  end

  def next_text_part
    part     = @message[0...MESSAGE_LIMIT]
    @message = @message[MESSAGE_LIMIT..] || ''
    part
  end
end
