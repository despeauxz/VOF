class DropAverageRatings < ActiveRecord::Migration[5.0]
  def change
    drop_view :average_ratings
  end
end
