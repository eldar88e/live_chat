class Chat < ApplicationRecord
  belongs_to :chat_widget
  belongs_to :lead, optional: true
  has_many :messages, dependent: :destroy

  validates :external_id, presence: true, uniqueness: { scope: :chat_widget_id }
  validate :lead_belongs_to_widget

  private

  def lead_belongs_to_widget
    errors.add(:lead, 'должен принадлежать этому виджету') if lead && lead.chat_widget_id != chat_widget_id
  end
end
