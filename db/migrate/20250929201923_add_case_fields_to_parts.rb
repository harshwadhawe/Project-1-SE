# frozen_string_literal: true

class AddCaseFieldsToParts < ActiveRecord::Migration[8.0]
  def change
    add_column :parts, :case_type, :string
    add_column :parts, :case_supported_mb, :string
    add_column :parts, :case_color, :string
  end
end
