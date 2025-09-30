classDiagram
  direction LR

  class User {
    id: integer
    name: string
    email: string (unique, downcased)
    -- validations --
    +valid_email
  }

  class Build {
    id: integer
    name: string
    total_wattage: integer (cached, optional)
    user_id: integer (nullable for now)
    -- methods --
    +parts()
    +recalculate_wattage()
  }

  class BuildItem {
    id: integer
    build_id: integer
    part_id: integer
    quantity: integer
    note: text
  }

  class Part {
    id: integer
    type: string  <<STI>>
    brand: string
    name: string
    model_number: string
    price_cents: integer
    wattage: integer  (0 if N/A)
  }

  class Cpu {
    cpu_cores: integer
    cpu_threads: integer
    cpu_core_clock: decimal (precision: 4, scale: 2)
    cpu_boost_clock: decimal (precision: 4, scale: 2)
  }

  class GPU {
    gpu_memory: integer           
    gpu_memory_type: string           #"GDDR6X", "GDDR6"
    gpu_core_clock_mhz: integer   
    gpu_core_boost_mhz: integer  
  }
  class Motherboard {
    mb_socket: string               #e.g., "AM5", "LGA1700"
    mb_chipset: string              #e.g., "B650", "Z790"
    mb_form_factor: string          #"ATX", "Micro-ATX", "Mini-ITX"
    mb_ram_slots: integer          
    mb_max_ram_gb: integer         
  }

  class Memory{
    mem_type: string                #e.g., "DDR5", "DDR4"
    mem_kit_capacity_gb: integer    #total memory size, e.g., 32 (2x16GB)
    mem_modules: integer            #2 in 2x16
    mem_speed_mhz: integer          #e.g., 6000, 3000
    mem_first_word_latency: integer #e.g., 10 (ns)     
  }
  class Storage{
    stor_type: string               #e.g., "SSD", "HDD"
    stor_interface: string          #e.g., "NVMe PCIe 4.0", "SATA III"
    stor_capacity_gb: integer       #(GB)
  }
  class Cooler{
    cooler_type: string             #e.g. "Air", "Liquid"
    cooler_fan_size_mm: integer     #e.g., 120, 140
    cooler_sockets: string          #e.g., "AM5, LGA1700, AM4"
  }
  class PcCase{
    case_type: string               #size, e.g. "Mid Tower", "SFF" (Small Form Factor)
    case_supported_mb: string       #e.g., "ATX, Micro-ATX, Mini-ITX"
    case_color: string              #e.g., "Black", "White"
  }
  class PSU{
    psu_efficiency: string          #e.g., "80+ Gold", "80+ Platinum"
    psu_modularity: string          #e.g., "Full", "Semi", "None"
    psu_wattage: string             #
  }

  User "1" -- "0..*" Build : owns
  Build "1" -- "1..*" BuildItem : has
  Part "1" -- "0..*" BuildItem : used in

  Part <|-- Cpu
  Part <|-- GPU
  Part <|-- Motherboard
  Part <|-- Memory
  Part <|-- Storage
  Part <|-- Cooler
  Part <|-- PcCase
  Part <|-- PSU
