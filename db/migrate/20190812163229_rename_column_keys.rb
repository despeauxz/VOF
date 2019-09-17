class RenameColumnKeys < ActiveRecord::Migration[5.0]
  def change
    rename_column :ratings, :new_panelist_id, :panelist_id
    rename_column :ratings, :new_learners_panel_id, :learners_panel_id
  end
end
