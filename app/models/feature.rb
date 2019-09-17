class Feature < ApplicationRecord
  has_many :permissions, dependent: :destroy
  validates :feature_name, presence: true, uniqueness: { case_sensitive: false }
end
