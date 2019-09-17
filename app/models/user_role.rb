class UserRole < ApplicationRecord
  belongs_to :role
  has_many :permissions, through: :role
  before_save { email.downcase! }
  # rubocop:disable Style/MutableConstant
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # rubocop:enable Style/MutableConstant
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
end
