class Membership < ApplicationRecord
  belongs_to :chat_widget
  belongs_to :user

  enum :role, { read: 0, write: 1 }

  validates :user_id, uniqueness: { scope: :chat_widget_id }
  validate :user_is_not_owner

  private

  def user_is_not_owner
    return unless chat_widget && user

    errors.add(:user, 'является владельцем виджета') if chat_widget.owner_id == user_id
  end
end
