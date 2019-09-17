class Role < ApplicationRecord
  has_many :permissions, dependent: :destroy
  has_many :user_roles
  validates :role_name, presence: true
end
