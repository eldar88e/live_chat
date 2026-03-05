class Chat < ApplicationRecord
  belongs_to :chat_widget
  has_many :messages, dependent: :destroy

  validates :external_id, presence: true, uniqueness: { scope: :chat_widget_id }
end
