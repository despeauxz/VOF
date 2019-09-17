class AddTemporaryTables < ActiveRecord::Migration[5.0]
  def change
    create_table :new_learners_panels do |t|
      t.string "camper_id"
      t.references :panel, foreign_key: true
    
      t.timestamps
    end
    add_foreign_key :new_learners_panels, :bootcampers, column: :camper_id, primary_key: :camper_id

    create_table :new_panelists do |t|
      t.string :email
      t.string :accepted, :default => false
      t.references :panel, foreign_key: true
    
      t.timestamps
    end
    create_table :new_ratings do |t|
      t.references :new_learners_panel, foreign_key: true
      t.references :new_panelist, foreign_key: true
      t.integer :ui_ux
      t.integer :api_functionality
      t.integer :error_handling
      t.integer :project_understanding
      t.integer :presentational_skill
      t.string :decision
      t.text :comment
    
      t.timestamps
    end
  end
end
