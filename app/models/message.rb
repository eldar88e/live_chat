class Message < ApplicationRecord
  belongs_to :chat

  enum :role, { client: 0, bot: 1, manager: 2 }

  validates :content, presence: true, length: { maximum: 1000 },
                      format: {
                        without: /\A\s*\z/,
                        message: I18n.t('activerecord.errors.models.messages.attributes.blank_or_spaces')
                      }

  after_create_commit :broadcast_widget_chat, :broadcast_admin_chat, :notify_tg

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end

  private

  def broadcast_widget_chat
    payload = { content: content, role: role, created_at: created_at.strftime('%H:%M') }
    CableBroadcastJob.perform_later("chat_#{chat_id}", payload)
  end

  def broadcast_admin_chat
    broadcast_append_later_to(
      "admin_chat_#{chat_id}", partial: '/admin/messages/msg', locals: { message: self }, target: 'messages'
    )
  end

  def notify_tg
    return unless (role == 'client') && Rails.env.production?

    chat_widget = chat.chat_widget
    tg_id       = chat_widget.tg_id
    token       = chat_widget.tg_token
    domain      = chat_widget.domain
    markups     = { markup_ext_url: "https://#{domain}/admin/messages?chat_id=#{chat_id}", markup_ext_text: 'Ответить' }
    TelegramSenderJob.perform_later(msg: content, id: tg_id, token: token, markups: markups)
  end
end
