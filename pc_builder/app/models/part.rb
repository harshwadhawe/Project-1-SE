class Part < ApplicationRecord
  self.inheritance_column = :type # STI
  has_many :build_items
  has_many :builds, through: :build_items

  validates :name, :brand, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :wattage, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end

class Cpu < Part; end
class GPU < Part; end
class Motherboard < Part; end
class Memory < Part; end
class Storage < Part; end
class Cooler < Part; end
class Case < Part; end
class PSU < Part; end
