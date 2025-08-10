class Membership < ApplicationRecord
  belongs_to :chat_widget
  belongs_to :user
end
