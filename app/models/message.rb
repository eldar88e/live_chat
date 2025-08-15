class Message < ApplicationRecord
  belongs_to :chat

  enum :role, { client: 0, bot: 1, manager: 2 }

  validates :content, presence: true, length: { maximum: 1000 },
                      format: {
                        without: /\A\s*\z/,
                        message: I18n.t('errors.messages.blank_or_spaces')
                      }

  after_create_commit :broadcast_message

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end

  private

  def broadcast_message
    broadcast_append_later_to(
      "chat_#{chat_id}", partial: '/admin/messages/msg', locals: { message: self }, target: 'messages'
    )

    CableBroadcastJob.perform_later(
      "chat_#{chat_id}",
      { content: content, role: role, created_at: created_at.strftime('%H:%M') }
    )
    TelegramSenderJob.perform_later(content) if (role == 'client') && Rails.env.production?
  end
end
