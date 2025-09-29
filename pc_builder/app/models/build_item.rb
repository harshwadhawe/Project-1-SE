class BuildItem < ApplicationRecord
  belongs_to :build
  belongs_to :part
  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true
end
