class AddPsuFieldsToParts < ActiveRecord::Migration[8.0]
  def change
    add_column :parts, :psu_efficiency, :string
    add_column :parts, :psu_modularity, :string
    add_column :parts, :psu_wattage, :string
  end
end
