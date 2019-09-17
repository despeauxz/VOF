class UpdateAverageRatingsToVersion2 < ActiveRecord::Migration[5.0]
  def change
    create_view :average_ratings, version: 2
  end
end
