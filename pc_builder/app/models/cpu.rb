class Cpu < Part
  # light validations – only when present so seeds/forms can be partial
  validates :cpu_cores, :cpu_threads, numericality: { greater_than: 0 }, allow_nil: true
  # validates :cpu_base_ghz, :cpu_boost_ghz, numericality: { greater_than: 0 }, allow_nil: true
  # validates :cpu_tdp_w, :cpu_cache_mb, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
