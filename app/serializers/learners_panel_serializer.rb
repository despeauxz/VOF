class LearnersPanelSerializer < ActiveModel::Serializer
  attributes :id, :rated
  belongs_to :bootcamper
  belongs_to :panel
  def rated
    object.ratings.any?
  end
end
