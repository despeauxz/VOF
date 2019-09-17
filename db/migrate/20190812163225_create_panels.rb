class CreatePanels < ActiveRecord::Migration[5.0]
  def change
    create_table :panels do |t|
      t.references :pitch
      t.string :panel_name

      t.timestamps
    end
  end
end
