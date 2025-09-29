# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the `bin/rails db:seed` command (or created alongside the database with `bin/rails db:setup`).
#
# To ensure the seed process is idempotent (can be run multiple times without creating duplicates),
# we will destroy all existing parts first.

puts "Destroying existing parts..."
Part.destroy_all
puts "Existing parts destroyed."

puts "Seeding new parts..."

# Wrapping the creation in a transaction ensures that if any record fails, all previous creations in this block are rolled back.
ActiveRecord::Base.transaction do
  # ===================================================================
  # CPUs
  # ===================================================================
  Cpu.create!([
    {
      brand: "Intel",
      name: "Core i7-13700K",
      model_number: "BX8071513700K",
      price_cents: 38999,
      wattage: 125,
      cpu_cores: 16,
      cpu_threads: 24,
      cpu_core_clock: 3.4,
      cpu_boost_clock: 5.4
    },
    {
      brand: "AMD",
      name: "Ryzen 7 7800X3D",
      model_number: "100-100000910WOF",
      price_cents: 39900,
      wattage: 120,
      cpu_cores: 8,
      cpu_threads: 16,
      cpu_core_clock: 4.2,
      cpu_boost_clock: 5.0
    }
  ])

  # ===================================================================
  # # GPUs (Graphics Cards)
  # ===================================================================
  Gpu.create!([
    {
      brand: "NVIDIA",
      name: "GeForce RTX 4070 SUPER",
      model_number: "900-1G141-2534-000",
      price_cents: 59999,
      wattage: 220,
      gpu_memory: 12,
      gpu_memory_type: "GDDR6X",
      gpu_core_clock_mhz: 1980,
      gpu_core_boost_mhz: 2475
    },
    {
      brand: "AMD",
      name: "Radeon RX 7800 XT",
      model_number: "MBA-7800XT-16G",
      price_cents: 49900,
      wattage: 263,
      gpu_memory: 16,
      gpu_memory_type: "GDDR6",
      gpu_core_clock_mhz: 2124,
      gpu_core_boost_mhz: 2430
    }
  ])

  # ===================================================================
  # Motherboards
  # ===================================================================
  Motherboard.create!([
    {
      brand: "ASUS",
      name: "TUF GAMING Z790-PLUS WIFI",
      model_number: "TUF GAMING Z790-PLUS WIFI",
      price_cents: 22999,
      wattage: 0,
      mb_socket: "LGA1700",
      mb_chipset: "Z790",
      mb_form_factor: "ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 128
    },
    {
      brand: "Gigabyte",
      name: "B650 AORUS ELITE AX",
      model_number: "B650 AORUS ELITE AX",
      price_cents: 21999,
      wattage: 0,
      mb_socket: "AM5",
      mb_chipset: "B650",
      mb_form_factor: "ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 128
    }
  ])

  # ===================================================================
  # Memory (RAM)
  # ===================================================================
  Memory.create!([
    {
      brand: "G.Skill",
      name: "Ripjaws S5",
      model_number: "F5-6000J3238F16GX2-RS5K",
      price_cents: 9499,
      wattage: 0,
      mem_type: "DDR5",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 6000,
      mem_first_word_latency: 10
    },
    {
      brand: "Corsair",
      name: "Vengeance LPX",
      model_number: "CMK32GX4M2E3200C16",
      price_cents: 6999,
      wattage: 0,
      mem_type: "DDR4",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 3200,
      mem_first_word_latency: 11
    }
  ])

  # ===================================================================
  # Storage
  # ===================================================================
  Storage.create!([
    {
      brand: "Samsung",
      name: "980 Pro",
      model_number: "MZ-V8P1T0B/AM",
      price_cents: 9999,
      wattage: 0,
      stor_type: "SSD",
      stor_interface: "NVMe PCIe 4.0",
      stor_capacity_gb: 1000
    },
    {
      brand: "Seagate",
      name: "Barracuda Compute",
      model_number: "ST2000DM008",
      price_cents: 5499,
      wattage: 0,
      stor_type: "HDD",
      stor_interface: "SATA III",
      stor_capacity_gb: 2000
    }
  ])

  # ===================================================================
  # Coolers
  # ===================================================================
  Cooler.create!([
    {
      brand: "Noctua",
      name: "NH-D15",
      model_number: "NH-D15",
      price_cents: 10995,
      wattage: 0,
      cooler_type: "Air",
      cooler_fan_size_mm: 140,
      cooler_sockets: "AM5, AM4, LGA1700, LGA1200"
    },
    {
      brand: "Corsair",
      name: "iCUE H150i ELITE CAPELLIX XT",
      model_number: "CW-9060070-WW",
      price_cents: 21999,
      wattage: 0,
      cooler_type: "Liquid",
      cooler_fan_size_mm: 120,
      cooler_sockets: "AM5, AM4, LGA1700, LGA1200"
    }
  ])

  # ===================================================================
  # Cases
  # ===================================================================
  Case.create!([
    {
      brand: "Lian Li",
      name: "O11 Dynamic EVO",
      model_number: "O11DEX",
      price_cents: 16999,
      wattage: 0,
      case_type: "Mid Tower",
      case_supported_mb: "ATX, Micro-ATX, Mini-ITX",
      case_color: "Black"
    },
    {
      brand: "Cooler Master",
      name: "MasterBox NR200P",
      model_number: "MCB-NR200P-KGNN-S00",
      price_cents: 10499,
      wattage: 0,
      case_type: "SFF",
      case_supported_mb: "Mini-ITX",
      case_color: "Black"
    }
  ])

  # ===================================================================
  # PSUs (Power Supply Units)
  # ===================================================================
  Psu.create!([
    {
      brand: "Corsair",
      name: "RM850e",
      model_number: "CP-9020263-NA",
      price_cents: 11999,
      wattage: 850, # The main wattage is inherited from Part
      psu_efficiency: "80+ Gold",
      psu_modularity: "Full",
      # psu_wattage is a string in your diagram, but the integer `wattage` field is more useful.
      # If you need this field, you can set it to "850W".
      psu_wattage: "850W"
    },
    {
      brand: "SeaSonic",
      name: "FOCUS Plus Gold",
      model_number: "SSR-750FX",
      price_cents: 10499,
      wattage: 750,
      psu_efficiency: "80+ Gold",
      psu_modularity: "Full",
      psu_wattage: "750W"
    }
  ])
end

puts "Finished seeding database."
puts "Created #{Part.count} parts in total."

