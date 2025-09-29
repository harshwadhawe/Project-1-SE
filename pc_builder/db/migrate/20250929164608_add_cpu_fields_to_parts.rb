class AddCpuFieldsToParts < ActiveRecord::Migration[7.1]
  def change
    add_column :parts, :cpu_cores, :integer
    add_column :parts, :cpu_threads, :integer
    add_column :parts, :cpu_base_ghz, :decimal, precision: 4, scale: 2
    add_column :parts, :cpu_boost_ghz, :decimal, precision: 4, scale: 2
    add_column :parts, :cpu_socket, :string
    add_column :parts, :cpu_tdp_w, :integer
    add_column :parts, :cpu_cache_mb, :integer
    add_column :parts, :cpu_igpu, :string
  end
end
