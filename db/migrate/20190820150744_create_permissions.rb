class CreatePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :permissions do |t|
      t.string :feature
      t.references :role, foreign_key: true
      t.string :permission_name
      t.boolean :permission_status, default: false

      t.timestamps
    end
  end
end
