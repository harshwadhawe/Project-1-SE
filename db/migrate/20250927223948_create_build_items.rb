# frozen_string_literal: true

class CreateBuildItems < ActiveRecord::Migration[8.0]
  def change
    create_table :build_items do |t|
      t.references :build, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.integer :quantity
      t.text :note

      t.timestamps
    end
  end
end
