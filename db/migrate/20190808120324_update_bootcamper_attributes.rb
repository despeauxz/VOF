class UpdateBootcamperAttributes < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :github_pages, :text
    add_column :bootcampers, :story_board, :text
    add_column :bootcampers, :challenge_one, :text
    add_column :bootcampers, :challenge_two, :text
    add_column :bootcampers, :challenge_three, :text
    add_column :bootcampers, :challenge_four, :text
    add_column :bootcampers, :heroku_one, :text
    add_column :bootcampers, :heroku_two, :text
    end
end
