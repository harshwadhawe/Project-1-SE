class AddCoolerFieldsToParts < ActiveRecord::Migration[8.0]
  def change
    add_column :parts, :cooler_type, :string
    add_column :parts, :cooler_fan_size_mm, :integer
    add_column :parts, :cooler_sockets, :string
  end
end
