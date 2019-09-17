class CreateFeatures < ActiveRecord::Migration[5.0]
  def change
    create_table :features do |t|
      t.string :feature_name, null: false
      t.timestamps
    end
    add_index :features, :feature_name, unique: true
  end
end
