# frozen_string_literal: true

class AddGpuFieldsToParts < ActiveRecord::Migration[8.0]
  def change
    add_column :parts, :gpu_memory, :integer
    add_column :parts, :gpu_memory_type, :string
    add_column :parts, :gpu_core_clock_mhz, :integer
    add_column :parts, :gpu_core_boost_mhz, :integer
  end
end
