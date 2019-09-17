class Panel < ApplicationRecord
  belongs_to :pitch
  has_many :learners_panels, dependent: :destroy
  has_many :new_learners_panels
  has_many :panelists, dependent: :destroy
  has_many :new_panelists
  has_one :cycle_center, through: :pitch
  has_many :ratings, through: :learners_panels
  validates :pitch_id, presence: true
end
