class Part < ApplicationRecord
  self.inheritance_column = :type # STI
  has_many :build_items
  has_many :builds, through: :build_items

  validates :name, :brand, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :wattage, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_create :log_part_creation
  after_create :log_part_created
  before_destroy :log_part_destruction
  after_validation :log_validation_results
  after_update :log_part_updated

  # Class method to log part queries
  def self.log_query(scope_name, count)
    Rails.logger.debug "[PART QUERY] #{scope_name}: Found #{count} #{self.name.downcase} parts"
  end

  # Instance methods with logging
  def price_in_dollars
    return 0 unless price_cents
    dollars = price_cents / 100.0
    Rails.logger.debug "[PART #{id}] Price conversion: #{price_cents} cents = $#{dollars}"
    dollars
  end

  def usage_count
    count = build_items.count
    Rails.logger.debug "[PART #{id}] Used in #{count} builds"
    count
  end

  private

  def log_part_creation
    Rails.logger.info "[PART CREATE] Creating new #{type || 'Part'}: #{brand} #{name} - $#{price_in_dollars}, #{wattage || 0}W"
  end

  def log_part_created
    Rails.logger.info "[PART CREATED] Successfully created #{type} ID: #{id} - #{brand} #{name}"
  end

  def log_part_destruction
    Rails.logger.warn "[PART DESTROY] Destroying #{type} ID: #{id} - #{brand} #{name} (used in #{build_items.count} builds)"
  end

  def log_validation_results
    if errors.any?
      Rails.logger.warn "[PART VALIDATION] Validation failed for #{type} '#{brand} #{name}': #{errors.full_messages.join(', ')}"
    else
      Rails.logger.debug "[PART VALIDATION] Validation passed for #{type} '#{brand} #{name}'"
    end
  end

  def log_part_updated
    if saved_changes.any?
      Rails.logger.info "[PART UPDATED] #{type} ID: #{id} updated - Changes: #{saved_changes.except('updated_at').inspect}"
    end
  end
end

class Cpu < Part
  after_initialize :log_cpu_initialization, if: :persisted?

  private

  def log_cpu_initialization
    Rails.logger.debug "[CPU] Initialized CPU: #{brand} #{name}" if brand && name
  end
end

class Gpu < Part
  after_initialize :log_gpu_initialization, if: :persisted?

  private

  def log_gpu_initialization
    Rails.logger.debug "[GPU] Initialized GPU: #{brand} #{name}" if brand && name
  end
end

class Motherboard < Part
  after_initialize :log_motherboard_initialization, if: :persisted?

  private

  def log_motherboard_initialization
    Rails.logger.debug "[MOTHERBOARD] Initialized Motherboard: #{brand} #{name}" if brand && name
  end
end

class Memory < Part
  after_initialize :log_memory_initialization, if: :persisted?

  private

  def log_memory_initialization
    Rails.logger.debug "[MEMORY] Initialized Memory: #{brand} #{name}" if brand && name
  end
end

class Storage < Part
  after_initialize :log_storage_initialization, if: :persisted?

  private

  def log_storage_initialization
    Rails.logger.debug "[STORAGE] Initialized Storage: #{brand} #{name}" if brand && name
  end
end

class Cooler < Part
  after_initialize :log_cooler_initialization, if: :persisted?

  private

  def log_cooler_initialization
    Rails.logger.debug "[COOLER] Initialized Cooler: #{brand} #{name}" if brand && name
  end
end

class PcCase < Part
  after_initialize :log_case_initialization, if: :persisted?

  private

  def log_case_initialization
    Rails.logger.debug "[CASE] Initialized Case: #{brand} #{name}" if brand && name
  end
end

class Psu < Part
  after_initialize :log_psu_initialization, if: :persisted?

  private

  def log_psu_initialization
    Rails.logger.debug "[PSU] Initialized PSU: #{brand} #{name}" if brand && name
  end
end
