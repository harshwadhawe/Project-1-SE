# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Seeding database..."

User.find_or_create_by!(email: "harsh@example.com") do |u|
  u.name = "Harsh"
end

# CPU
Cpu.find_or_create_by!(brand: "AMD", name: "Ryzen 7 7800X3D", model_number: "7800X3D") do |p|
  p.price_cents = 39900
  p.wattage = 120
end
Cpu.find_or_create_by!(brand: "Intel", name: "Core i7-14700K", model_number: "i7-14700K") do |p|
  p.price_cents = 41900
  p.wattage = 125
end

# GPU
Gpu.find_or_create_by!(brand: "NVIDIA", name: "RTX 4080 Super", model_number: "RTX4080S") do |p|
  p.price_cents = 119900
  p.wattage = 320
end
Gpu.find_or_create_by!(brand: "AMD", name: "Radeon RX 7900 XT", model_number: "RX7900XT") do |p|
  p.price_cents = 89900
  p.wattage = 300
end

# Motherboard
Motherboard.find_or_create_by!(brand: "ASUS", name: "ROG Strix B650E-F", model_number: "B650E-F") do |p|
  p.price_cents = 25900
  p.wattage = 30
end
Motherboard.find_or_create_by!(brand: "MSI", name: "MAG Z790 Tomahawk", model_number: "Z790TOMAHAWK") do |p|
  p.price_cents = 28900
  p.wattage = 35
end

# Memory
Memory.find_or_create_by!(brand: "G.Skill", name: "Trident Z5 RGB 32GB DDR5-6000", model_number: "F5-6000J3238F16GX2-TZ5RK") do |p|
  p.price_cents = 16900
  p.wattage = 10
end
Memory.find_or_create_by!(brand: "Corsair", name: "Vengeance DDR5 64GB (2x32GB)", model_number: "CMK64GX5M2B5600C40") do |p|
  p.price_cents = 25900
  p.wattage = 12
end

# Storage
Storage.find_or_create_by!(brand: "Samsung", name: "990 Pro 2TB NVMe SSD", model_number: "MZ-V9P2T0BW") do |p|
  p.price_cents = 21900
  p.wattage = 8
end
Storage.find_or_create_by!(brand: "Western Digital", name: "Black SN850X 4TB NVMe", model_number: "WDS400T2X0E") do |p|
  p.price_cents = 39900
  p.wattage = 10
end

# Cooler
Cooler.find_or_create_by!(brand: "Noctua", name: "NH-D15", model_number: "NH-D15") do |p|
  p.price_cents = 9990
  p.wattage = 5
end
Cooler.find_or_create_by!(brand: "Corsair", name: "iCUE H150i Elite Capellix XT", model_number: "CW-9060065-WW") do |p|
  p.price_cents = 18900
  p.wattage = 6
end

# Case (PcCase)
PcCase.find_or_create_by!(brand: "Fractal Design", name: "Meshify 2", model_number: "FD-C-MES2A-03") do |p|
  p.price_cents = 16900
  p.wattage = 0
end
PcCase.find_or_create_by!(brand: "NZXT", name: "H7 Flow", model_number: "CM-H71FB-01") do |p|
  p.price_cents = 13900
  p.wattage = 0
end

# PSU
Psu.find_or_create_by!(brand: "Corsair", name: "RM850x 850W Gold", model_number: "CP-9020200-NA") do |p|
  p.price_cents = 13900
  p.wattage = 0
end
Psu.find_or_create_by!(brand: "Seasonic", name: "Prime TX-1000 1000W Titanium", model_number: "SSR-1000TR") do |p|
  p.price_cents = 24900
  p.wattage = 0
end

puts "Seeded: #{User.count} users, #{Cpu.count} CPUs, #{Gpu.count} GPUs, #{Motherboard.count} motherboards, #{Memory.count} memory kits, #{Storage.count} storage drives, #{Cooler.count} coolers, #{PcCase.count} cases, #{Psu.count} PSUs"
