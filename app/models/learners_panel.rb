class LearnersPanel < ApplicationRecord
  belongs_to :panel
  belongs_to :bootcamper, foreign_key: :camper_id
  has_many :ratings, dependent: :destroy
  validates :camper_id, presence: true
  validates :panel_id, presence: true

  def graded?
    ratings.any?
  end
end
