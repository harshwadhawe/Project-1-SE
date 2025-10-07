# frozen_string_literal: true

class Cpu < Part
  # light validations – only when present so seeds/forms can be partial
  validates :cpu_cores, :cpu_threads, numericality: { greater_than: 0 }, allow_nil: true
  # validates :cpu_base_ghz, :cpu_boost_ghz, numericality: { greater_than: 0 }, allow_nil: true
  # validates :cpu_tdp_w, :cpu_cache_mb, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  after_validation :log_cpu_validation

  def specs_summary
    summary = "#{cpu_cores}C/#{cpu_threads}T @ #{cpu_core_clock}GHz (#{cpu_boost_clock}GHz boost), #{wattage}W TDP"
    Rails.logger.debug "[CPU #{id}] Specs: #{summary}"
    summary
  end

  private

  def log_cpu_validation
    if errors.any?
      Rails.logger.warn "[CPU VALIDATION] CPU validation failed for #{brand} #{name}: #{errors.full_messages.join(', ')}"
    else
      Rails.logger.debug "[CPU VALIDATION] CPU validation passed for #{brand} #{name}"
      if cpu_cores && cpu_threads
        Rails.logger.debug "[CPU SPECS] #{brand} #{name}: #{cpu_cores}C/#{cpu_threads}T, #{cpu_core_clock}/#{cpu_boost_clock}GHz, #{wattage}W"
      end
    end
  end
end
