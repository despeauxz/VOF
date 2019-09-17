class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :user_roles do |t|
      t.string :email
      t.references :role, foreign_key: true

      t.timestamps
    end
  end
end
