class RenamePitchTableColumns < ActiveRecord::Migration[5.0]
  def change
    drop_table :ratings
    drop_table :learners_pitches
    drop_table :panelists
    rename_table("new_learners_panels", "learners_panels")
    rename_table("new_panelists", "panelists")
    rename_table("new_ratings", "ratings")
  end
end
