class AddMemoryFieldsToParts < ActiveRecord::Migration[8.0]
  def change
    add_column :parts, :mem_type, :string
    add_column :parts, :mem_kit_capacity_gb, :integer
    add_column :parts, :mem_modules, :integer
    add_column :parts, :mem_speed_mhz, :integer
    add_column :parts, :mem_first_word_latency, :integer
  end
end
