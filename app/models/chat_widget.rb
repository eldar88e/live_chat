class ChatWidget < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  has_many :chats, dependent: :destroy
  # has_many :visitors,      dependent: :destroy

  before_validation :normalize_domain
  validates :name, :domain, :token_digest, presence: true
  validates :domain, uniqueness: true

  def rotate_token!
    raw               = SecureRandom.urlsafe_base64(48)
    self.token_hash   = Digest::SHA256.hexdigest(raw)
    self.token_digest = BCrypt::Password.create(raw, cost: 12)
    save!
    raw
  end

  def valid_token?(raw)
    return false if raw.blank? || token_digest.blank?

    BCrypt::Password.new(token_digest).is_password?(raw)
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def self.find_by_token(raw)
    hash   = Digest::SHA256.hexdigest(raw)
    find_by!(token_hash: hash)
  end

  private

  def normalize_domain
    return if domain.blank?

    self.domain = domain.to_s.strip.downcase.sub(%r{\Ahttps?://}, '').delete_suffix('/')
  end
end
