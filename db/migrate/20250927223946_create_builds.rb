class CreateBuilds < ActiveRecord::Migration[8.0]
  def change
    create_table :builds do |t|
      t.string :name
      t.integer :total_wattage
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
