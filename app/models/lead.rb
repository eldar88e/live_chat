class Lead < ApplicationRecord
  belongs_to :chat_widget
  has_many :chats, dependent: :nullify

  scope :for_widget, ->(id) { where(chat_widget_id: id) if id.present? }
  scope :for_chat, ->(id) { where(id: Chat.where(id: id).select(:lead_id)) if id.present? }

  before_validation :normalize_contacts

  validates :name, presence: true, length: { maximum: 100 }
  validates :phone, format: { with: /\A[0-9]{7,15}\z/ }, allow_nil: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 254 }, allow_nil: true
  validate :contact_present

  private

  def normalize_contacts
    self.name = name.to_s.strip
    self.email = email.to_s.strip.downcase.presence
    self.phone = phone.to_s.gsub(/[\s().-]/, '').delete_prefix('+').presence
  end

  def contact_present
    errors.add(:base, 'Укажите телефон или email') if phone.blank? && email.blank?
  end
end
