class CreateParts < ActiveRecord::Migration[8.0]
  def change
    create_table :parts do |t|
      t.string :type
      t.string :brand
      t.string :name
      t.string :model_number
      t.integer :price_cents
      t.integer :wattage

      t.timestamps
    end
  end
end
