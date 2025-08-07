class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { user: 0, manager: 1, moderator: 2, admin: 3 }

  def admin?
    role == 'admin'
  end

  def moderator?
    role == 'moderator'
  end

  def manager?
    role == 'manager'
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id created_at role email]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end
end
