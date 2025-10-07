# frozen_string_literal: true

class AddStorageFieldsToParts < ActiveRecord::Migration[8.0]
  def change
    add_column :parts, :stor_type, :string
    add_column :parts, :stor_interface, :string
    add_column :parts, :stor_capacity_gb, :integer
  end
end
