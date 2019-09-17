class Pitch < ApplicationRecord
  has_many :panels, dependent: :destroy
  belongs_to :cycle_center, foreign_key: :cycle_center_id
  has_many :learner_programs, through: :cycle_center
  has_many :learners_panels, through: :panels
  has_many :panelists, through: :panels
  validates :cycle_center_id, presence: true
  validates :demo_date, presence: true

  def ratings
    panels.map(&:ratings).flatten
  end
end
