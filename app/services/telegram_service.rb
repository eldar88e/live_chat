require 'telegram/bot'

class TelegramService
  MESSAGE_LIMIT = 4_090

  def initialize(**args)
    @bot_token = args[:token] || settings[:tg_token]
    @chat_ids  = args[:id] || settings[:chat_ids]
    @message   = args[:msg]
    @markups   = args[:markups]
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
    markup        = build_markup
    message_count.times do
      text_part = next_text_part
      send_telegram_message(text_part, markup)
    end
    @message_id
  end

  def send_telegram_message(text_part, markup)
    [@chat_ids.to_s.split(',')].flatten.each do |chat_id|
      Telegram::Bot::Client.run(@bot_token) do |bot|
        @message_id = bot.api.send_message(
          chat_id: chat_id, text: escape(text_part), parse_mode: 'MarkdownV2', reply_markup: markup
        ).message_id
      end
    rescue StandardError => e
      Rails.logger.error "Failed to send message to bot: #{e.message}"
      @message_id = e
    end
  end

  def next_text_part
    part     = @message[0...MESSAGE_LIMIT]
    @message = @message[MESSAGE_LIMIT..] || ''
    part
  end

  def build_markup
    Tg::MarkupService.call(@markups)
  end
end
