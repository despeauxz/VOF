class RenameFeatureToFeatureId < ActiveRecord::Migration[5.0]
  def change
    change_column :permissions, :feature, 'integer USING CAST(feature AS integer)'
    rename_column :permissions, :feature, :feature_id
    add_foreign_key :permissions, :features
  end
end
