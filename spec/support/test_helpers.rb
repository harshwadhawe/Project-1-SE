# frozen_string_literal: true

# spec/support/test_helpers.rb
module TestHelpers
  def make_user(email: 'harsh@example.com', name: 'Harsh', password: 'password123')
    User.find_or_create_by!(email:) do |u|
      u.name = name
      u.password = password
    end
  end

  def cpu(attrs = {})
    Cpu.create!({ brand: 'AMD', name: 'Ryzen 7 7800X3D', model_number: '7800X3D',
                  price_cents: 39_900, wattage: 120, cpu_core_clock: 4.2,
                  cpu_boost_clock: 5.0, cpu_cores: 8, cpu_threads: 16 }.merge(attrs))
  end

  def gpu(attrs = {})
    Gpu.create!({ brand: 'NVIDIA', name: 'RTX 4080 Super', model_number: 'RTX4080S',
                  price_cents: 119_900, wattage: 320, gpu_memory: 16,
                  gpu_memory_type: 'GDDR6X', gpu_core_clock_mhz: 2205, gpu_core_boost_mhz: 2550 }.merge(attrs))
  end

  def motherboard(attrs = {})
    Motherboard.create!({ brand: 'ASUS', name: 'ROG Strix B650E-F', model_number: 'B650E-F',
                          price_cents: 25_900, wattage: 30 }.merge(attrs))
  end

  def memory(attrs = {})
    Memory.create!({ brand: 'G.Skill', name: 'Trident Z5 32GB', model_number: 'F5-6000',
                     price_cents: 16_900, wattage: 10 }.merge(attrs))
  end

  def storage(attrs = {})
    Storage.create!({ brand: 'Samsung', name: '990 Pro 2TB', model_number: 'MZ-V9P2T0',
                      price_cents: 21_900, wattage: 8 }.merge(attrs))
  end

  def cooler(attrs = {})
    Cooler.create!({ brand: 'Noctua', name: 'NH-D15', model_number: 'NH-D15',
                     price_cents: 9990, wattage: 5, cooler_type: 'Air',
                     cooler_fan_size_mm: 140, cooler_sockets: 'AM4,AM5,LGA1700' }.merge(attrs))
  end

  def pc_case(attrs = {})
    PcCase.create!({ brand: 'Fractal', name: 'Meshify 2', model_number: 'FD-C-MES2A-03',
                     price_cents: 16_900, wattage: 0 }.merge(attrs))
  end

  def psu(attrs = {})
    Psu.create!({ brand: 'Corsair', name: 'RM850x', model_number: 'CP-9020200-NA',
                  price_cents: 13_900, wattage: 0 }.merge(attrs))
  end
end
