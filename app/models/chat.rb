class Chat < ApplicationRecord
  belongs_to :chat_widget
  has_many :messages, dependent: :destroy
end
