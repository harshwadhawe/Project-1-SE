# frozen_string_literal: true

class AddCpuFieldsToParts < ActiveRecord::Migration[8.0]
  def change
    add_column :parts, :cpu_cores, :integer
    add_column :parts, :cpu_threads, :integer
    add_column :parts, :cpu_core_clock, :decimal
    add_column :parts, :cpu_boost_clock, :decimal
  end
end
