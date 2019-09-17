class AddCreatedbyToPanels < ActiveRecord::Migration[5.0]
  def change
    add_column :panels, :created_by, :string
  end
end
