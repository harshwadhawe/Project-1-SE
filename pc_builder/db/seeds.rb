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
  # CPUs (10 items)
  # ===================================================================
  Cpu.create!([
    {
      brand: "Intel",
      name: "Core i9-14900K",
      model_number: "BX8071514900K",
      price_cents: 54999,
      wattage: 125,
      cpu_cores: 24,
      cpu_threads: 32,
      cpu_core_clock: 3.2,
      cpu_boost_clock: 6.0
    },
    {
      brand: "AMD",
      name: "Ryzen 9 7950X",
      model_number: "100-100000514WOF",
      price_cents: 54900,
      wattage: 170,
      cpu_cores: 16,
      cpu_threads: 32,
      cpu_core_clock: 4.5,
      cpu_boost_clock: 5.7
    },
    {
      brand: "Intel",
      name: "Core i7-14700K",
      model_number: "BX8071514700K",
      price_cents: 38999,
      wattage: 125,
      cpu_cores: 20,
      cpu_threads: 28,
      cpu_core_clock: 3.4,
      cpu_boost_clock: 5.6
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
    },
    {
      brand: "Intel",
      name: "Core i5-14600K",
      model_number: "BX8071514600K",
      price_cents: 29499,
      wattage: 125,
      cpu_cores: 14,
      cpu_threads: 20,
      cpu_core_clock: 3.5,
      cpu_boost_clock: 5.3
    },
    {
      brand: "AMD",
      name: "Ryzen 7 5800X3D",
      model_number: "100-100000651WOF",
      price_cents: 32900,
      wattage: 105,
      cpu_cores: 8,
      cpu_threads: 16,
      cpu_core_clock: 3.4,
      cpu_boost_clock: 4.5
    },
    {
      brand: "Intel",
      name: "Core i5-13400F",
      model_number: "BX8071513400F",
      price_cents: 18499,
      wattage: 65,
      cpu_cores: 10,
      cpu_threads: 16,
      cpu_core_clock: 2.5,
      cpu_boost_clock: 4.6
    },
    {
      brand: "AMD",
      name: "Ryzen 5 7600",
      model_number: "100-100001015BOX",
      price_cents: 21999,
      wattage: 65,
      cpu_cores: 6,
      cpu_threads: 12,
      cpu_core_clock: 3.8,
      cpu_boost_clock: 5.1
    },
    {
      brand: "Intel",
      name: "Core i3-13100F",
      model_number: "BX8071513100F",
      price_cents: 10999,
      wattage: 58,
      cpu_cores: 4,
      cpu_threads: 8,
      cpu_core_clock: 3.4,
      cpu_boost_clock: 4.5
    },
    {
      brand: "AMD",
      name: "Ryzen 5 5600G",
      model_number: "100-100000252BOX",
      price_cents: 12999,
      wattage: 65,
      cpu_cores: 6,
      cpu_threads: 12,
      cpu_core_clock: 3.9,
      cpu_boost_clock: 4.4
    }
  ])

  # ===================================================================
  # GPUs (Graphics Cards) (10 items)
  # ===================================================================
  Gpu.create!([
    {
      brand: "NVIDIA",
      name: "GeForce RTX 4090",
      model_number: "900-1G136-2530-000",
      price_cents: 179999,
      wattage: 450,
      gpu_memory: 24,
      gpu_memory_type: "GDDR6X",
      gpu_core_clock_mhz: 2235,
      gpu_core_boost_mhz: 2520
    },
    {
      brand: "AMD",
      name: "Radeon RX 7900 XTX",
      model_number: "100-300000000",
      price_cents: 92999,
      wattage: 355,
      gpu_memory: 24,
      gpu_memory_type: "GDDR6",
      gpu_core_clock_mhz: 2300,
      gpu_core_boost_mhz: 2500
    },
    {
      brand: "NVIDIA",
      name: "GeForce RTX 4080 SUPER",
      model_number: "900-1G136-2550-000",
      price_cents: 99999,
      wattage: 320,
      gpu_memory: 16,
      gpu_memory_type: "GDDR6X",
      gpu_core_clock_mhz: 2295,
      gpu_core_boost_mhz: 2550
    },
    {
      brand: "AMD",
      name: "Radeon RX 7900 XT",
      model_number: "102-D0270100-00",
      price_cents: 74999,
      wattage: 315,
      gpu_memory: 20,
      gpu_memory_type: "GDDR6",
      gpu_core_clock_mhz: 2000,
      gpu_core_boost_mhz: 2400
    },
    {
      brand: "NVIDIA",
      name: "GeForce RTX 4070 Ti SUPER",
      model_number: "900-1G133-2530-000",
      price_cents: 79999,
      wattage: 285,
      gpu_memory: 16,
      gpu_memory_type: "GDDR6X",
      gpu_core_clock_mhz: 2340,
      gpu_core_boost_mhz: 2610
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
    },
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
      name: "Radeon RX 7700 XT",
      model_number: "11335-02-20G",
      price_cents: 43999,
      wattage: 245,
      gpu_memory: 12,
      gpu_memory_type: "GDDR6",
      gpu_core_clock_mhz: 2171,
      gpu_core_boost_mhz: 2544
    },
    {
      brand: "NVIDIA",
      name: "GeForce RTX 4060",
      model_number: "900-1G141-2540-000",
      price_cents: 29999,
      wattage: 115,
      gpu_memory: 8,
      gpu_memory_type: "GDDR6",
      gpu_core_clock_mhz: 1830,
      gpu_core_boost_mhz: 2460
    },
    {
      brand: "Intel",
      name: "Arc A770",
      model_number: "21P01J00BA",
      price_cents: 26999,
      wattage: 225,
      gpu_memory: 16,
      gpu_memory_type: "GDDR6",
      gpu_core_clock_mhz: 2100,
      gpu_core_boost_mhz: 2400
    }
  ])

  # ===================================================================
  # Motherboards (10 items)
  # ===================================================================
  Motherboard.create!([
    {
      brand: "ASUS",
      name: "ROG STRIX Z790-E GAMING WIFI II",
      model_number: "ROG STRIX Z790-E GAMING WIFI II",
      price_cents: 57999,
      wattage: 0,
      mb_socket: "LGA1700",
      mb_chipset: "Z790",
      mb_form_factor: "ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 192
    },
    {
      brand: "Gigabyte",
      name: "X670 AORUS ELITE AX",
      model_number: "X670 AORUS ELITE AX",
      price_cents: 27999,
      wattage: 0,
      mb_socket: "AM5",
      mb_chipset: "X670",
      mb_form_factor: "ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 128
    },
    {
      brand: "MSI",
      name: "MAG B760 TOMAHAWK WIFI",
      model_number: "MAG B760 TOMAHAWK WIFI",
      price_cents: 19999,
      wattage: 0,
      mb_socket: "LGA1700",
      mb_chipset: "B760",
      mb_form_factor: "ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 128
    },
    {
      brand: "ASRock",
      name: "B650M PG RIPTIDE WIFI",
      model_number: "B650M PG RIPTIDE WIFI",
      price_cents: 18999,
      wattage: 0,
      mb_socket: "AM5",
      mb_chipset: "B650",
      mb_form_factor: "Micro-ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 128
    },
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
    },
    {
      brand: "MSI",
      name: "PRO Z790-A WIFI",
      model_number: "PRO Z790-A WIFI",
      price_cents: 23999,
      wattage: 0,
      mb_socket: "LGA1700",
      mb_chipset: "Z790",
      mb_form_factor: "ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 192
    },
    {
      brand: "ASRock",
      name: "X670E Steel Legend",
      model_number: "X670E Steel Legend",
      price_cents: 28999,
      wattage: 0,
      mb_socket: "AM5",
      mb_chipset: "X670E",
      mb_form_factor: "ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 128
    },
    {
      brand: "ASUS",
      name: "ROG STRIX B650E-F GAMING WIFI",
      model_number: "ROG STRIX B650E-F GAMING WIFI",
      price_cents: 27999,
      wattage: 0,
      mb_socket: "AM5",
      mb_chipset: "B650E",
      mb_form_factor: "ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 128
    },
    {
      brand: "Gigabyte",
      name: "Z790 AORUS ELITE AX",
      model_number: "Z790 AORUS ELITE AX",
      price_cents: 25499,
      wattage: 0,
      mb_socket: "LGA1700",
      mb_chipset: "Z790",
      mb_form_factor: "ATX",
      mb_ram_slots: 4,
      mb_max_ram_gb: 192
    }
  ])

  # ===================================================================
  # Memory (RAM) (10 items)
  # ===================================================================
  Memory.create!([
    {
      brand: "Corsair",
      name: "Vengeance RGB",
      model_number: "CMH32GX5M2B6000C40",
      price_cents: 11499,
      wattage: 0,
      mem_type: "DDR5",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 6000,
      mem_first_word_latency: 13.33
    },
    {
      brand: "G.Skill",
      name: "Trident Z5 RGB",
      model_number: "F5-6000J3636F16GX2-TZ5RK",
      price_cents: 11999,
      wattage: 0,
      mem_type: "DDR5",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 6000,
      mem_first_word_latency: 12
    },
    {
      brand: "Crucial",
      name: "Pro",
      model_number: "CP2K16G56C46U5",
      price_cents: 8999,
      wattage: 0,
      mem_type: "DDR5",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 5600,
      mem_first_word_latency: 11.4
    },
    {
      brand: "Kingston",
      name: "FURY Beast",
      model_number: "KF552C40BBK2-32",
      price_cents: 9999,
      wattage: 0,
      mem_type: "DDR5",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 5200,
      mem_first_word_latency: 15.38
    },
    {
      brand: "Teamgroup",
      name: "T-Force Delta RGB",
      model_number: "FF3D532G6400HC40BDC01",
      price_cents: 10999,
      wattage: 0,
      mem_type: "DDR5",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 6400,
      mem_first_word_latency: 12.5
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
      mem_first_word_latency: 10
    },
    {
      brand: "G.Skill",
      name: "Ripjaws V",
      model_number: "F4-3600C16D-32GVKC",
      price_cents: 8499,
      wattage: 0,
      mem_type: "DDR4",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 3600,
      mem_first_word_latency: 8.89
    },
    {
      brand: "Crucial",
      name: "Ballistix",
      model_number: "BL2K16G36C16U4B",
      price_cents: 9999,
      wattage: 0,
      mem_type: "DDR4",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 3600,
      mem_first_word_latency: 8.89
    },
    {
      brand: "Kingston",
      name: "FURY Beast",
      model_number: "KF432C16BB1K2/32",
      price_cents: 7499,
      wattage: 0,
      mem_type: "DDR4",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 3200,
      mem_first_word_latency: 10
    },
    {
      brand: "Teamgroup",
      name: "T-FORCE VULCAN Z",
      model_number: "TLZGD432G3200HC16FDC01",
      price_cents: 6299,
      wattage: 0,
      mem_type: "DDR4",
      mem_kit_capacity_gb: 32,
      mem_modules: 2,
      mem_speed_mhz: 3200,
      mem_first_word_latency: 10
    }
  ])

  # ===================================================================
  # Storage (10 items)
  # ===================================================================
  Storage.create!([
    {
      brand: "Samsung",
      name: "990 Pro",
      model_number: "MZ-V9P2T0B/AM",
      price_cents: 16999,
      wattage: 0,
      stor_type: "SSD",
      stor_interface: "NVMe PCIe 4.0",
      stor_capacity_gb: 2000
    },
    {
      brand: "Western Digital",
      name: "Black SN850X",
      model_number: "WDS200T2X0E",
      price_cents: 15999,
      wattage: 0,
      stor_type: "SSD",
      stor_interface: "NVMe PCIe 4.0",
      stor_capacity_gb: 2000
    },
    {
      brand: "Crucial",
      name: "P5 Plus",
      model_number: "CT2000P5PSSD8",
      price_cents: 14999,
      wattage: 0,
      stor_type: "SSD",
      stor_interface: "NVMe PCIe 4.0",
      stor_capacity_gb: 2000
    },
    {
      brand: "Seagate",
      name: "FireCuda 530",
      model_number: "ZP2000GM3A013",
      price_cents: 17999,
      wattage: 0,
      stor_type: "SSD",
      stor_interface: "NVMe PCIe 4.0",
      stor_capacity_gb: 2000
    },
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
      brand: "SK Hynix",
      name: "Platinum P41",
      model_number: "SHPP41-2000GM-2",
      price_cents: 16999,
      wattage: 0,
      stor_type: "SSD",
      stor_interface: "NVMe PCIe 4.0",
      stor_capacity_gb: 2000
    },
    {
      brand: "Sabrent",
      name: "Rocket 4 Plus",
      model_number: "SB-RKT4P-2TB",
      price_cents: 15999,
      wattage: 0,
      stor_type: "SSD",
      stor_interface: "NVMe PCIe 4.0",
      stor_capacity_gb: 2000
    },
    {
      brand: "Samsung",
      name: "870 Evo",
      model_number: "MZ-77E1T0B/AM",
      price_cents: 7999,
      wattage: 0,
      stor_type: "SSD",
      stor_interface: "SATA III",
      stor_capacity_gb: 1000
    },
    {
      brand: "Seagate",
      name: "Barracuda Compute",
      model_number: "ST8000DM004",
      price_cents: 13999,
      wattage: 0,
      stor_type: "HDD",
      stor_interface: "SATA III",
      stor_capacity_gb: 8000
    },
    {
      brand: "Western Digital",
      name: "WD Blue",
      model_number: "WD40EZAZ",
      price_cents: 7999,
      wattage: 0,
      stor_type: "HDD",
      stor_interface: "SATA III",
      stor_capacity_gb: 4000
    }
  ])

  # ===================================================================
  # Coolers (10 items)
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
    },
    {
      brand: "Thermalright",
      name: "Peerless Assassin 120 SE",
      model_number: "PA120 SE",
      price_cents: 3590,
      wattage: 0,
      cooler_type: "Air",
      cooler_fan_size_mm: 120,
      cooler_sockets: "AM5, AM4, LGA1700, LGA1200"
    },
    {
      brand: "ARCTIC",
      name: "Liquid Freezer II 360",
      model_number: "ACFRE00068A",
      price_cents: 15499,
      wattage: 0,
      cooler_type: "Liquid",
      cooler_fan_size_mm: 120,
      cooler_sockets: "AM5, AM4, LGA1700"
    },
    {
      brand: "be quiet!",
      name: "Dark Rock Pro 4",
      model_number: "BK022",
      price_cents: 8990,
      wattage: 0,
      cooler_type: "Air",
      cooler_fan_size_mm: 135,
      cooler_sockets: "AM5, AM4, LGA1700, LGA1200"
    },
    {
      brand: "NZXT",
      name: "Kraken 240",
      model_number: "RL-KN240-B1",
      price_cents: 13999,
      wattage: 0,
      cooler_type: "Liquid",
      cooler_fan_size_mm: 120,
      cooler_sockets: "AM5, AM4, LGA1700, LGA1200"
    },
    {
      brand: "Deepcool",
      name: "AK620",
      model_number: "R-AK620-BKNNMT-G",
      price_cents: 6999,
      wattage: 0,
      cooler_type: "Air",
      cooler_fan_size_mm: 120,
      cooler_sockets: "AM5, AM4, LGA1700, LGA1200"
    },
    {
      brand: "Lian Li",
      name: "GALAHAD AIO 360",
      model_number: "GA-360A-B",
      price_cents: 16999,
      wattage: 0,
      cooler_type: "Liquid",
      cooler_fan_size_mm: 120,
      cooler_sockets: "AM5, AM4, LGA1700, LGA1200"
    },
    {
      brand: "Scythe",
      name: "Fuma 2",
      model_number: "SCFM-2000",
      price_cents: 6599,
      wattage: 0,
      cooler_type: "Air",
      cooler_fan_size_mm: 120,
      cooler_sockets: "AM4, LGA1700, LGA1200"
    },
    {
      brand: "EKWB",
      name: "EK-AIO Basic 240",
      model_number: "3831109852443",
      price_cents: 9999,
      wattage: 0,
      cooler_type: "Liquid",
      cooler_fan_size_mm: 120,
      cooler_sockets: "AM4, LGA1700, LGA1200"
    }
  ])

  # ===================================================================
  # Cases (10 items)
  # ===================================================================
  PcCase.create!([
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
      brand: "Corsair",
      name: "4000D Airflow",
      model_number: "CC-9011200-WW",
      price_cents: 9499,
      wattage: 0,
      case_type: "Mid Tower",
      case_supported_mb: "ATX, Micro-ATX, Mini-ITX",
      case_color: "Black"
    },
    {
      brand: "NZXT",
      name: "H7 Flow",
      model_number: "CM-H71FB-01",
      price_cents: 12999,
      wattage: 0,
      case_type: "Mid Tower",
      case_supported_mb: "ATX, Micro-ATX, Mini-ITX",
      case_color: "Black"
    },
    {
      brand: "Fractal Design",
      name: "Meshify C",
      model_number: "FD-CA-MESH-C-BKO-TG",
      price_cents: 9999,
      wattage: 0,
      case_type: "Mid Tower",
      case_supported_mb: "ATX, Micro-ATX, Mini-ITX",
      case_color: "Black"
    },
    {
      brand: "Phanteks",
      name: "Eclipse P400A",
      model_number: "PH-EC400ATG_DBK01",
      price_cents: 8999,
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
    },
    {
      brand: "be quiet!",
      name: "Pure Base 500DX",
      model_number: "BGW37",
      price_cents: 10990,
      wattage: 0,
      case_type: "Mid Tower",
      case_supported_mb: "ATX, Micro-ATX, Mini-ITX",
      case_color: "Black"
    },
    {
      brand: "Fractal Design",
      name: "Torrent",
      model_number: "FD-C-TOR1A-01",
      price_cents: 19999,
      wattage: 0,
      case_type: "Mid Tower",
      case_supported_mb: "ATX, E-ATX, Micro-ATX, Mini-ITX",
      case_color: "Black"
    },
    {
      brand: "Hyte",
      name: "Y60",
      model_number: "CS-HYTE-Y60-B",
      price_cents: 19999,
      wattage: 0,
      case_type: "Mid Tower",
      case_supported_mb: "ATX, Micro-ATX, Mini-ITX",
      case_color: "Black"
    },
    {
      brand: "Thermaltake",
      name: "Core P3",
      model_number: "CA-1G4-00M1WN-00",
      price_cents: 13999,
      wattage: 0,
      case_type: "Mid Tower",
      case_supported_mb: "ATX, Micro-ATX, Mini-ITX",
      case_color: "Black"
    }
  ])

  # ===================================================================
  # PSUs (Power Supply Units) (10 items)
  # ===================================================================
  Psu.create!([
    {
      brand: "Corsair",
      name: "RM1000x",
      model_number: "CP-9020201-NA",
      price_cents: 18999,
      wattage: 1000,
      psu_efficiency: "80+ Gold",
      psu_modularity: "Full",
      psu_wattage: "1000W"
    },
    {
      brand: "SeaSonic",
      name: "FOCUS PX-850",
      model_number: "SSR-850PX",
      price_cents: 15999,
      wattage: 850,
      psu_efficiency: "80+ Platinum",
      psu_modularity: "Full",
      psu_wattage: "850W"
    },
    {
      brand: "EVGA",
      name: "SuperNOVA 850 G6",
      model_number: "220-G6-0850-X1",
      price_cents: 14999,
      wattage: 850,
      psu_efficiency: "80+ Gold",
      psu_modularity: "Full",
      psu_wattage: "850W"
    },
    {
      brand: "be quiet!",
      name: "Straight Power 11",
      model_number: "BN644",
      price_cents: 17490,
      wattage: 1000,
      psu_efficiency: "80+ Platinum",
      psu_modularity: "Full",
      psu_wattage: "1000W"
    },
    {
      brand: "Corsair",
      name: "RM850e",
      model_number: "CP-9020263-NA",
      price_cents: 11999,
      wattage: 850,
      psu_efficiency: "80+ Gold",
      psu_modularity: "Full",
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
    },
    {
      brand: "Thermaltake",
      name: "Toughpower GF1",
      model_number: "PS-TPD-0750FNFAGU-1",
      price_cents: 10999,
      wattage: 750,
      psu_efficiency: "80+ Gold",
      psu_modularity: "Full",
      psu_wattage: "750W"
    },
    {
      brand: "EVGA",
      name: "SuperNOVA 750 G5",
      model_number: "220-G5-0750-X1",
      price_cents: 12999,
      wattage: 750,
      psu_efficiency: "80+ Gold",
      psu_modularity: "Full",
      psu_wattage: "750W"
    },
    {
      brand: "Cooler Master",
      name: "MWE Gold 750",
      model_number: "MPY-7501-AFAAG-US",
      price_cents: 9999,
      wattage: 750,
      psu_efficiency: "80+ Gold",
      psu_modularity: "Full",
      psu_wattage: "750W"
    },
    {
      brand: "Corsair",
      name: "SF750",
      model_number: "CP-9020186-NA",
      price_cents: 16999,
      wattage: 750,
      psu_efficiency: "80+ Platinum",
      psu_modularity: "Full",
      psu_wattage: "750W"
    }
  ])
end

puts "Finished seeding database."
puts "Created #{Part.count} parts in total."