# require 'telegram/bot'

module Tg
  class MarkupService
    def initialize(markups)
      @markups   = markups
      @keyboards = []
      # @app_url   = "https://t.me/#{settings[:tg_main_bot]}?startapp"
    end

    def self.call(markups)
      new(markups).form_markup
    end

    def form_markup
      return if @markups.blank?

      other_form_keyboards
      return if @keyboards.blank?

      Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: @keyboards)
    end

    private

    # def settings
    #   @settings ||= Setting.all_cached
    # end

    def other_form_keyboards
      @keyboards += form_ext_url_keyboard if @markups[:markup_ext_url].present?
      # @keyboards += form_url_keyboard if @markups[:markup_url].present?
    end

    # def form_url_keyboard(markup_url = nil, markup_text = nil)
    #   texts = [markup_text || @markups[:markup_text]].flatten
    #   [markup_url || @markups[:markup_url]].flatten.map.with_index do |path, idx|
    #     url = "#{@app_url}=url=#{path.gsub(%r{\A/|/\z}, '').tr('/', '_')}"
    #     form_url_btn(url, texts[idx])
    #   end
    # end

    def form_ext_url_keyboard
      texts = [@markups[:markup_ext_text]].flatten
      [@markups[:markup_ext_url]].flatten.map.with_index { |url, idx| form_url_btn(url, texts[idx]) }
    end

    def form_url_btn(url, text = 'Кнопка')
      [Telegram::Bot::Types::InlineKeyboardButton.new(text: text, url: url)]
    end
  end
end
