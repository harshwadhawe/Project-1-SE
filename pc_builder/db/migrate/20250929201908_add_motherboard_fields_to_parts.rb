class AddMotherboardFieldsToParts < ActiveRecord::Migration[8.0]
  def change
    add_column :parts, :mb_socket, :string
    add_column :parts, :mb_chipset, :string
    add_column :parts, :mb_form_factor, :string
    add_column :parts, :mb_ram_slots, :integer
    add_column :parts, :mb_max_ram_gb, :integer
  end
end
