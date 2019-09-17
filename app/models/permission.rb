class Permission < ApplicationRecord
  belongs_to :role
  belongs_to :feature
  validates :feature_id, presence: true
  validates :role_id, presence: true
  validates :permission_name, presence: true
end
